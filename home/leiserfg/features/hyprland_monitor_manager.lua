--[[
Hyprland Monitor Manager (Lua version)
Automatically manages monitor configuration:
- Sets optimal scale for eDP-1 (laptop screen) on startup
- Disables eDP-1 when external monitors are connected
- Re-enables eDP-1 when it's the only monitor remaining
]]

-- Constants
local WAYLAND_SCALE_STEP = 120 -- Wayland fractional-scale protocol uses 1/120 increments
local SCALE_SEARCH_RANGE = 90 -- Search ±90 increments (±0.75) from target scale
local EVENT_DEBOUNCE_DELAY = 500 -- Debounce delay for monitor events in milliseconds
local MIN_SCALE = 1
local MAX_SCALE = 4
local STEPS = 8 -- 0.125 increments
local MIN_LOGICAL_AREA = 800 * 480

-- Map from minimum diagonal size (in inches) to a target DPI
local SIZE_TO_TARGET_DPI = {
  { 0.0, 135.0 }, -- phones / laptops
  { 15.0, 150.0 }, -- medium monitors -> tuned to prefer ~1.5 scale
  { 27.0, 242.0 }, -- DELL S2721QS (27") -> tuned to prefer ~1.5 scale
  { 30.0, 185.0 }, -- ultrawide monitors -> tuned to prefer ~1.66 for the ultrawide
}

-- Global cache for monitor rules
local monitor_rules_cache = {}
local ideal_edp1_rule = nil
local debounce_timers = {}

---Helper function to find GCD
local function gcd(a, b)
  while b ~= 0 do
    a, b = b, a % b
  end
  return a
end

---Helper function to log to file
local function log_to_file(msg)
  local file = io.open("/tmp/monitors.log", "a")
  if file then
    file:write(msg .. "\n")
    file:flush()
    file:close()
  end
end

---Helper function to show notifications
local function notify(msg)
  log_to_file(msg)
  hl.notification.create({ text = msg, duration = 3000 })
end

---Check if a value is in a table
local function tbl_contains(table, value)
  for _, v in ipairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

---Round to nearest 1/WAYLAND_SCALE_STEP
local function closest_representable_scale(scale)
  return math.floor(scale * WAYLAND_SCALE_STEP + 0.5) / WAYLAND_SCALE_STEP
end

---Find valid scale for resolution, preferring whole logical pixels
local function find_valid_scale_for_resolution(width, height, target_scale)

  local search_scale = math.floor(target_scale * WAYLAND_SCALE_STEP + 0.5)
  local scale_zero = search_scale / WAYLAND_SCALE_STEP

  log_to_file(
    string.format("find_valid_scale: search_scale=%d, scale_zero=%.4f", search_scale, scale_zero)
  )

  local logical_width = width / scale_zero
  local logical_height = height / scale_zero

  log_to_file(
    string.format(
      "find_valid_scale: logical resolution would be %.2fx%.2f",
      logical_width,
      logical_height
    )
  )
  log_to_file(
    string.format(
      "find_valid_scale: differences from whole: w=%.6f, h=%.6f",
      math.abs(logical_width - math.floor(logical_width + 0.5)),
      math.abs(logical_height - math.floor(logical_height + 0.5))
    )
  )

  -- Check if close enough to whole pixels (within 0.01)
  if
    math.abs(logical_width - math.floor(logical_width + 0.5)) < 0.01
    and math.abs(logical_height - math.floor(logical_height + 0.5)) < 0.01
  then
    debug_log(
      string.format(
        "find_valid_scale: scale_zero passes tolerance check, returning %.4f",
        scale_zero
      )
    )
    return scale_zero
  end


  -- Search for nearest valid scale within ±SCALE_SEARCH_RANGE increments
  for i = 1, SCALE_SEARCH_RANGE - 1 do
    local scale_up = (search_scale + i) / WAYLAND_SCALE_STEP
    local scale_down = (search_scale - i) / WAYLAND_SCALE_STEP

    local found_up = false
    local found_down = false

    -- Try higher scale
    local logical_up_w = width / scale_up
    local logical_up_h = height / scale_up
    if
      math.abs(logical_up_w - math.floor(logical_up_w + 0.5)) < 0.01
      and math.abs(logical_up_h - math.floor(logical_up_h + 0.5)) < 0.01
    then
      found_up = true
      debug_log(
        string.format("find_valid_scale: found valid scale_up=%.4f at offset %d", scale_up, i)
      )
    end

    -- Try lower scale (ensure positive)
    if scale_down > 0 then
      local logical_down_w = width / scale_down
      local logical_down_h = height / scale_down
      if
        math.abs(logical_down_w - math.floor(logical_down_w + 0.5)) < 0.01
        and math.abs(logical_down_h - math.floor(logical_down_h + 0.5)) < 0.01
      then
        found_down = true
        debug_log(
          string.format("find_valid_scale: found valid scale_down=%.4f at offset %d", scale_down, i)
        )
      end
    end

    -- If both directions are valid, choose the one closer to the original target
    if found_up and found_down then
      if math.abs(scale_up - target_scale) <= math.abs(scale_down - target_scale) then
        return scale_up
      else
        return scale_down
      end
    elseif found_up then
      return scale_up
    elseif found_down then
      return scale_down
    end
  end

  -- If no perfect scale found, just use the rounded scale anyway
  debug_log(
    string.format("find_valid_scale: no perfect match found, returning scale_zero=%.4f", scale_zero)
  )
  return scale_zero
end

---Calculate optimal scale for a monitor
local function calculate_scale(width, height, physical_width_mm, physical_height_mm)
  -- If physical size is missing or invalid, default to 1.0
  if
    not physical_width_mm
    or not physical_height_mm
    or physical_width_mm <= 0
    or physical_height_mm <= 0
  then
    log_to_file("WARNING: Invalid physical dimensions - using scale 1.0. Width=" .. tostring(physical_width_mm) .. ", Height=" .. tostring(physical_height_mm))
    return 1.0
  end

  -- Compute diagonal size in inches
  local diag_mm = math.sqrt(physical_width_mm ^ 2 + physical_height_mm ^ 2)
  local diag_inches = diag_mm / 25.4

  -- Lookup target DPI from SIZE_TO_TARGET_DPI table
  local target_dpi = SIZE_TO_TARGET_DPI[1][2]
  for _, entry in ipairs(SIZE_TO_TARGET_DPI) do
    if diag_inches >= entry[1] then
      target_dpi = entry[2]
    else
      break
    end
  end

  -- Use vertical DPI for scaling
  local physical_height_in = physical_height_mm / 25.4
  local vertical_dpi = height / physical_height_in

  -- Calculate the 'perfect' scale
  local perfect_scale
  local small_threshold = (SIZE_TO_TARGET_DPI[2] and SIZE_TO_TARGET_DPI[2][1]) or math.huge
  if diag_inches < small_threshold then
    perfect_scale = vertical_dpi / target_dpi
  else
    perfect_scale = target_dpi / vertical_dpi
  end

  -- Candidate integer-producing scales using gcd method
  local candidates = {}
  local g = gcd(width, height)
  local t_min = math.max(1, math.ceil(g / MAX_SCALE))
  local t_max = math.max(1, math.floor(g / MIN_SCALE))

  for t = t_min, t_max do
    local scale_candidate = g / t

    -- Must be representable by compositor increments (1/WAYLAND_SCALE_STEP)
    local rounded = math.floor(scale_candidate * WAYLAND_SCALE_STEP + 0.5)
    if math.abs(rounded - scale_candidate * WAYLAND_SCALE_STEP) < 1e-9 then
      local logical_w = math.floor(width / scale_candidate)
      local logical_h = math.floor(height / scale_candidate)
      if logical_w * logical_h >= MIN_LOGICAL_AREA then
        table.insert(candidates, scale_candidate)
      end
    end
  end

  local best_scale
  if #candidates > 0 then
    -- Find candidate closest to perfect_scale
    best_scale = candidates[1]
    for _, sc in ipairs(candidates) do
      if math.abs(sc - perfect_scale) < math.abs(best_scale - perfect_scale) then
        best_scale = sc
      end
    end
    best_scale = closest_representable_scale(best_scale)
  else
    -- Fallback: use supported scales
    local supported_scales = {}
    for i = MIN_SCALE * STEPS, MAX_SCALE * STEPS do
      local scale = i / STEPS
      local logical_width = math.floor(width / scale)
      local logical_height = math.floor(height / scale)
      local logical_area = logical_width * logical_height
      if logical_area >= MIN_LOGICAL_AREA then
        table.insert(supported_scales, scale)
      end
    end

    if #supported_scales == 0 then
      return 1.0
    end

    best_scale = supported_scales[1]
    for _, sc in ipairs(supported_scales) do
      if math.abs(sc - perfect_scale) < math.abs(best_scale - perfect_scale) then
        best_scale = sc
      end
    end
  end

  -- Validate to prefer whole logical pixels
  local valid_scale = find_valid_scale_for_resolution(width, height, best_scale)
  return valid_scale
end

---Get list of all monitors
local function get_all_monitors()
  local monitors = hl.get_monitors()
  return monitors
end

---Get monitor by name from all monitors (including disabled)
local function get_monitor_info(monitor_name)
  local monitors = get_all_monitors()
  for _, monitor in ipairs(monitors) do
    if monitor.name == monitor_name then
      return monitor
    end
  end
  return nil
end

---Get the best mode (resolution and refresh rate) for a monitor
local function get_best_mode_for_monitor(monitor)
  if not monitor or not monitor.modes or #monitor.modes == 0 then
    return {
      width = monitor.width or 1920,
      height = monitor.height or 1080,
      refresh = monitor.refreshRate or 60.0,
    }
  end

  -- Parse available modes and find the best one
  local modes = {}
  for _, mode_str in ipairs(monitor.modes) do
    -- Mode format: "1920x1080@60.00Hz"
    local width, height, refresh = string.match(mode_str, "(%d+)x(%d+)@([%d.]+)Hz")
    if width and height and refresh then
      table.insert(modes, {
        width = tonumber(width),
        height = tonumber(height),
        refresh = tonumber(refresh),
      })
    end
  end

  if #modes == 0 then
    return {
      width = monitor.width or 1920,
      height = monitor.height or 1080,
      refresh = monitor.refreshRate or 60.0,
    }
  end

  -- Filter modes with > 59Hz (some monitors use fractional rates)
  local high_refresh_modes = {}
  for _, mode in ipairs(modes) do
    if mode.refresh > 59.0 then
      table.insert(high_refresh_modes, mode)
    end
  end

  local best_mode
  if #high_refresh_modes > 0 then
    -- Pick highest resolution among high refresh modes
    best_mode = high_refresh_modes[1]
    for _, mode in ipairs(high_refresh_modes) do
      local pixels = mode.width * mode.height
      local best_pixels = best_mode.width * best_mode.height
      if pixels > best_pixels or (pixels == best_pixels and mode.refresh > best_mode.refresh) then
        best_mode = mode
      end
    end
  else
    -- No 60Hz+ modes, just pick highest resolution
    best_mode = modes[1]
    for _, mode in ipairs(modes) do
      local pixels = mode.width * mode.height
      local best_pixels = best_mode.width * best_mode.height
      if pixels > best_pixels or (pixels == best_pixels and mode.refresh > best_mode.refresh) then
        best_mode = mode
      end
    end
  end

  return best_mode
end

---Create ideal monitor rule for a monitor
local function create_ideal_monitor_rule(monitor_name, monitor)
  if not monitor then
    notify("Monitor " .. monitor_name .. " not found!")
    return nil
  end

  local desc = monitor.description or monitor_name

  -- Get the best mode
  local mode = get_best_mode_for_monitor(monitor)
  local width, height, refresh = mode.width, mode.height, mode.refresh

  -- Get physical dimensions
  local physical_width_mm = monitor.physicalWidth
  local physical_height_mm = monitor.physicalHeight
  

  local scale
  if
    not physical_width_mm
    or not physical_height_mm
    or physical_width_mm <= 0
    or physical_height_mm <= 0
  then
    -- Physical dimensions not available from Hyprland API
    -- Use the scale that Hyprland has already determined
    log_to_file("Physical dimensions not available - using Hyprland provided scale: " .. tostring(monitor.scale))
    scale = monitor.scale or 1.0
  else
    -- Calculate scale from physical dimensions
    log_to_file("Calculating scale for " .. monitor_name .. "...")
    scale = calculate_scale(width, height, physical_width_mm, physical_height_mm)
  end

  -- Create the monitor rule
  local rule =
    string.format("monitor desc:%s,%dx%d@%.0f,auto,%.4f", desc, width, height, refresh, scale)

  notify(
    string.format(
      "%s: %dx%d@%.0fHz, scale=%.2f",
      monitor_name,
      width,
      height,
      refresh,
      scale
    )
  )

  return {
    name = monitor_name,
    desc = desc,
    rule = rule,
    width = width,
    height = height,
    refresh = refresh,
    scale = scale,
  }
end

---Apply a monitor rule
local function apply_monitor_rule(rule)
  if not rule then
    return false
  end

  local mode_str = string.format("%dx%d@%.0f", rule.width, rule.height, rule.refresh)
  hl.monitor {
    output = rule.name,
    mode = mode_str,
    position = "auto",
    scale = rule.scale,
  }
  return true
end

---Get list of active monitor names
local function get_active_monitor_names()
  local monitors = hl.get_monitors()
  local names = {}
  for _, monitor in ipairs(monitors) do
    if not monitor.disabled then
      table.insert(names, monitor.name)
    end
  end
  return names
end

---Disable eDP-1 monitor
local function disable_edp1()
  notify("Disabling eDP-1")
  hl.monitor {
    output = "eDP-1",
    disabled = true,
  }
end

---Enable eDP-1 with ideal rule
local function enable_edp1(rule)
  if not rule then
    return
  end

  notify(
    string.format(
      "Enabling eDP-1: %dx%d@%.0fHz, scale=%.2f",
      rule.width,
      rule.height,
      rule.refresh,
      rule.scale
    )
  )

  local mode_str = string.format("%dx%d@%.0f", rule.width, rule.height, rule.refresh)
  hl.monitor {
    output = "eDP-1",
    disabled = false,
    mode = mode_str,
    position = "auto",
    scale = rule.scale,
  }
end

---Configure all external monitors
local function configure_all_external_monitors()
  local monitors = hl.get_monitors()

  for _, monitor in ipairs(monitors) do
    local monitor_name = monitor.name
    if monitor_name ~= "eDP-1" and not monitor.disabled then
      local monitor_desc = monitor.description or monitor_name

      local rule
      if monitor_rules_cache[monitor_desc] then
        rule = monitor_rules_cache[monitor_desc]
      else
        rule = create_ideal_monitor_rule(monitor_name, monitor)
        if rule then
          monitor_rules_cache[monitor_desc] = rule
        end
      end

      if rule then
        apply_monitor_rule(rule)
      else
        notify("Failed to configure " .. monitor_name)
      end
    end
  end
end

---Print cache contents (silent)
local function print_cache()
  -- Cache debug info is silent
end

---Handle monitor added event
local function on_monitor_added(monitor_name)
  -- Set debounce timer to handle the monitor with a delay
  if debounce_timers[monitor_name] then
    debounce_timers[monitor_name]:set_enabled(false)
  end

  debounce_timers[monitor_name] = hl.timer(function()
    if monitor_name ~= "eDP-1" then
      -- External monitor connected
      local monitor_info = get_monitor_info(monitor_name)
      if not monitor_info then
        notify("Could not get info for " .. monitor_name)
        return
      end

      local monitor_desc = monitor_info.description or monitor_name

      local rule
      if monitor_rules_cache[monitor_desc] then
        rule = monitor_rules_cache[monitor_desc]
      else
        rule = create_ideal_monitor_rule(monitor_name, monitor_info)
        if rule then
          monitor_rules_cache[monitor_desc] = rule
        end
      end

      if rule then
        apply_monitor_rule(rule)
        -- Small delay to let configuration apply
        hl.timer(function() end, { timeout = 200 })
      else
        notify("Could not create rule for " .. monitor_name)
      end

      -- Disable eDP-1 if external monitors are active
      local active_monitors = get_active_monitor_names()

      if tbl_contains(active_monitors, "eDP-1") then
        disable_edp1()
      end
    else
      -- eDP-1 was added (resume from sleep)
      notify("eDP-1 reconnected")

      -- Re-apply all cached external monitor rules
      for desc, rule in pairs(monitor_rules_cache) do
        if rule.name ~= "eDP-1" then
          apply_monitor_rule(rule)
        end
      end

      local active_monitors = get_active_monitor_names()

      local external_active = {}
      for _, m in ipairs(active_monitors) do
        if m ~= "eDP-1" then
          table.insert(external_active, m)
        end
      end

      if #external_active > 0 then
        notify("External monitors present, disabling eDP-1")
        disable_edp1()
      else
        enable_edp1(ideal_edp1_rule)
      end
    end

    debounce_timers[monitor_name] = nil
  end, { timeout = EVENT_DEBOUNCE_DELAY, type = "oneshot" })
end

---Handle monitor removed event
local function on_monitor_removed(monitor_name)
  -- Set debounce timer
  if debounce_timers[monitor_name] then
    debounce_timers[monitor_name]:set_enabled(false)
  end

  debounce_timers[monitor_name] = hl.timer(function()
    if monitor_name ~= "eDP-1" then
      -- External monitor disconnected
      local active_monitors = get_active_monitor_names()

      if #active_monitors == 0 or (#active_monitors == 1 and active_monitors[1] == "eDP-1") then
        notify("Monitor " .. monitor_name .. " disconnected")
        enable_edp1(ideal_edp1_rule)
      end
    end

    debounce_timers[monitor_name] = nil
  end, { timeout = EVENT_DEBOUNCE_DELAY, type = "oneshot" })
end

---Initialize the monitor manager
local function init()
  notify("Monitor Manager starting")

  -- Wait a bit for monitors to be initialized
  hl.timer(function()
    -- Step 1: Calculate ideal eDP-1 rule
    local edp1_info = get_monitor_info "eDP-1"
    if not edp1_info then
      -- Try to get all monitors for debugging
      local all_monitors = get_all_monitors()
      local monitor_names = {}
      for _, m in ipairs(all_monitors) do
        table.insert(monitor_names, m.name)
      end
      log_to_file("Available monitors: " .. table.concat(monitor_names, ", "))
      notify("Error: Could not find eDP-1 monitor. Available: " .. table.concat(monitor_names, ", "))
      return
    end

    ideal_edp1_rule = create_ideal_monitor_rule("eDP-1", edp1_info)
    if not ideal_edp1_rule then
      notify("Error: Failed to create eDP-1 rule")
      return
    end

    monitor_rules_cache[ideal_edp1_rule.desc] = ideal_edp1_rule

    -- Step 2: Check current monitor setup
    configure_all_external_monitors()

    local active_monitors = get_active_monitor_names()

    -- If there are external monitors, disable eDP-1
    local external_monitors = {}
    for _, m in ipairs(active_monitors) do
      if m ~= "eDP-1" then
        table.insert(external_monitors, m)
      end
    end

    if #external_monitors > 0 then
      if tbl_contains(active_monitors, "eDP-1") then
        disable_edp1()
      end
    else
      enable_edp1(ideal_edp1_rule)
    end

    -- Register event listeners
    hl.on("monitor.added", function(monitor)
      on_monitor_added(monitor.name)
    end)

    hl.on("monitor.removed", function(monitor)
      on_monitor_removed(monitor.name)
    end)

    notify("Monitor Manager initialized")
  end, { timeout = 1000, type = "oneshot" })
end

-- Initialize on startup
init()
