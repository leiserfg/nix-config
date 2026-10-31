-- Monitor manager for Hyprland's Lua configuration.
-- Load this file from the Hyprland Lua config (for example with dofile).
-- It uses Hyprland's Lua API directly; it does not use hyprctl or IPC sockets.

hl.config {
  debug = {
    disable_logs = true,
  },
}

-- Keep diagnostic call sites available without emitting output.
local function log(_) end

local WAYLAND_SCALE_STEP = 120
local SCALE_SEARCH_RANGE = 90
local MIN_SCALE = 1
local MAX_SCALE = 4
local SCALE_STEPS = 8
local MIN_LOGICAL_AREA = 800 * 480

local SIZE_TO_TARGET_DPI = {
  { 0.0, 135.0 },
  { 15.0, 150.0 },
  { 27.0, 242.0 },
  { 30.0, 185.0 },
}

local function round(value)
  -- All values passed here are positive, matching Python's round() behavior
  -- for the scale values used by this algorithm.
  return math.floor(value + 0.5)
end

local function gcd(a, b)
  while b ~= 0 do
    a, b = b, a % b
  end
  return a
end

local function is_whole(value)
  return math.abs(value - round(value)) < 0.01
end

local function closest_representable_scale(scale)
  return round(scale * WAYLAND_SCALE_STEP) / WAYLAND_SCALE_STEP
end

local function find_valid_scale_for_resolution(width, height, target_scale)
  local search_scale = round(target_scale * WAYLAND_SCALE_STEP)
  local scale_zero = search_scale / WAYLAND_SCALE_STEP

  if is_whole(width / scale_zero) and is_whole(height / scale_zero) then
    return scale_zero
  end

  for i = 1, SCALE_SEARCH_RANGE - 1 do
    local scale_up = (search_scale + i) / WAYLAND_SCALE_STEP
    local scale_down = (search_scale - i) / WAYLAND_SCALE_STEP
    local found_up = is_whole(width / scale_up) and is_whole(height / scale_up)
    local found_down = scale_down > 0
      and is_whole(width / scale_down)
      and is_whole(height / scale_down)

    if found_up and found_down then
      if math.abs(scale_up - target_scale) <= math.abs(scale_down - target_scale) then
        return scale_up
      end
      return scale_down
    elseif found_up then
      return scale_up
    elseif found_down then
      return scale_down
    end
  end

  return scale_zero
end

local function calculate_scale(width, height, physical_width_mm, physical_height_mm)
  if
    not physical_width_mm
    or not physical_height_mm
    or physical_width_mm <= 0
    or physical_height_mm <= 0
  then
    return 1.0
  end

  local diagonal_inches = math.sqrt(
    physical_width_mm * physical_width_mm + physical_height_mm * physical_height_mm
  ) / 25.4

  local target_dpi = SIZE_TO_TARGET_DPI[1][2]
  for _, entry in ipairs(SIZE_TO_TARGET_DPI) do
    if diagonal_inches >= entry[1] then
      target_dpi = entry[2]
    else
      break
    end
  end

  local physical_height_inches = physical_height_mm / 25.4
  local physical_dpi = height / physical_height_inches
  local perfect_scale
  if diagonal_inches < SIZE_TO_TARGET_DPI[2][1] then
    perfect_scale = physical_dpi / target_dpi
  else
    perfect_scale = target_dpi / physical_dpi
  end

  local common_divisor = gcd(width, height)
  local candidates = {}
  local t_min = math.max(1, math.ceil(common_divisor / MAX_SCALE))
  local t_max = math.max(1, math.floor(common_divisor / MIN_SCALE))

  for t = t_min, t_max do
    local candidate = common_divisor / t
    if math.abs(round(candidate * WAYLAND_SCALE_STEP) - candidate * WAYLAND_SCALE_STEP) <= 1e-9 then
      local logical_width = math.floor(width / candidate)
      local logical_height = math.floor(height / candidate)
      if logical_width * logical_height >= MIN_LOGICAL_AREA then
        candidates[#candidates + 1] = candidate
      end
    end
  end

  local best_scale
  if #candidates > 0 then
    best_scale = candidates[1]
    for i = 2, #candidates do
      if math.abs(candidates[i] - perfect_scale) < math.abs(best_scale - perfect_scale) then
        best_scale = candidates[i]
      end
    end
    best_scale = closest_representable_scale(best_scale)
  else
    local supported_scales = {}
    for i = MIN_SCALE * SCALE_STEPS, MAX_SCALE * SCALE_STEPS do
      local scale = i / SCALE_STEPS
      local logical_width = math.floor(width / scale)
      local logical_height = math.floor(height / scale)
      if logical_width * logical_height >= MIN_LOGICAL_AREA then
        supported_scales[#supported_scales + 1] = scale
      end
    end

    if #supported_scales == 0 then
      return 1.0
    end

    best_scale = supported_scales[1]
    for i = 2, #supported_scales do
      if math.abs(supported_scales[i] - perfect_scale) < math.abs(best_scale - perfect_scale) then
        best_scale = supported_scales[i]
      end
    end
  end

  return find_valid_scale_for_resolution(width, height, best_scale)
end

local function parse_mode(mode_string)
  if type(mode_string) ~= "string" then
    return nil
  end

  local width, height, rate = mode_string:match "^(%d+)x(%d+)@([%d%.]+)Hz$"
  if not width then
    return nil
  end

  return {
    width = tonumber(width),
    height = tonumber(height),
    refresh_rate = tonumber(rate),
    mode_string = mode_string,
  }
end

local function best_mode(monitor)
  -- The Lua API exposes available_modes as MonitorMode objects, unlike the
  -- hyprctl JSON representation which contains availableModes strings.
  local modes = monitor.available_modes or monitor.availableModes or {}
  local best

  for _, available_mode in ipairs(modes) do
    local mode
    if type(available_mode) == "string" then
      mode = parse_mode(available_mode)
    elseif type(available_mode) == "table" then
      local width = available_mode.width
      local height = available_mode.height
      local refresh_rate = available_mode.refresh_rate or available_mode.refreshRate
      if width and height and refresh_rate then
        mode = {
          width = width,
          height = height,
          refresh_rate = refresh_rate,
          mode_string = string.format("%dx%d@%.2fHz", width, height, refresh_rate),
        }
      end
    end

    if
      mode
      and (
        not best
        or mode.height > best.height
        or (mode.height == best.height and mode.width > best.width)
        or (
          mode.height == best.height
          and mode.width == best.width
          and mode.refresh_rate > best.refresh_rate
        )
      )
    then
      best = mode
    end
  end

  return best
end

local function configure_monitor(monitor, force_enable)
  local mode = best_mode(monitor)
  if not mode then
    log("No usable modes reported for " .. tostring(monitor.name))
    return
  end

  local scale = calculate_scale(
    mode.width,
    mode.height,
    monitor.physical_width or monitor.physicalWidth,
    monitor.physical_height or monitor.physicalHeight
  )

  local needs_update = force_enable == true
    or mode.width ~= monitor.width
    or mode.height ~= monitor.height
    or math.abs(mode.refresh_rate - (monitor.refresh_rate or monitor.refreshRate or 0)) > 1e-6
    or math.abs(scale - (monitor.scale or 1.0)) > 1e-6

  if needs_update then
    log(
      string.format(
        "Configuring %s: mode=%s scale=%.3f (was %dx%d @ %.3f, scale %.3f, disabled=%s)",
        monitor.name,
        mode.mode_string,
        scale,
        monitor.width or 0,
        monitor.height or 0,
        monitor.refresh_rate or monitor.refreshRate or 0,
        monitor.scale or 1.0,
        tostring(force_enable == true)
      )
    )
    hl.monitor {
      output = monitor.name,
      disabled = false,
      scale = scale,
      position = "auto",
      mode = mode.mode_string,
    }
  else
    log(monitor.name .. " already matches the preferred mode and scale")
  end
end

local function is_internal_monitor(monitor)
  local name = monitor.name or ""
  return name:match "^eDP%-" ~= nil or name:match "^LVDS%-" ~= nil or name:match "^DSI%-" ~= nil
end

local function setup_monitors()
  local active_monitors = hl.get_monitors()
  local all_monitors = hl.get_monitors { all = true }
  if type(active_monitors) ~= "table" or type(all_monitors) ~= "table" then
    return
  end

  log(
    string.format(
      "Checking monitors: %d active, %d known including inactive",
      #active_monitors,
      #all_monitors
    )
  )

  local active_count = 0
  for _, monitor in ipairs(active_monitors) do
    if monitor.name ~= "FALLBACK" and monitor.disabled ~= true then
      active_count = active_count + 1
      configure_monitor(monitor)
    end
  end

  -- Keep disabled outputs disabled while any real monitor is active. If none
  -- remain, bring up one built-in panel as a fallback display.
  if active_count == 0 then
    log "No active monitors; looking for a built-in display fallback"
    local found_internal = false
    for _, monitor in ipairs(all_monitors) do
      if monitor.name ~= "FALLBACK" and is_internal_monitor(monitor) then
        log("Using built-in display " .. monitor.name)
        configure_monitor(monitor, true)
        found_internal = true
        break
      end
    end
    if not found_internal then
      log "No built-in display found; leaving monitor state unchanged"
    end
  end
end

-- Monitor connect/disconnect and reload events can arrive close together.
-- A short timer coalesces them and lets Hyprland finish updating monitor data.
local debounce_timer
debounce_timer = hl.timer(function()
  debounce_timer:set_enabled(false)
  log "Running debounced monitor setup"
  setup_monitors()
end, { timeout = 200, type = "repeat" })
debounce_timer:set_enabled(false)

local function schedule_setup(event_name)
  log("Received " .. event_name .. "; scheduling monitor check")
  debounce_timer:set_enabled(false)
  debounce_timer:set_enabled(true)
end

local function setup_immediately(event_name)
  log("Received " .. event_name .. "; handling immediately")
  debounce_timer:set_enabled(false)
  setup_monitors()
end

hl.on("hyprland.start", function()
  setup_immediately "hyprland.start"
end)
hl.on("monitor.added", function()
  schedule_setup "monitor.added"
end)
hl.on("monitor.removed", function()
  setup_immediately "monitor.removed"
end)
hl.on("config.reloaded", function()
  setup_immediately "config.reloaded"
end)

setup_immediately "script.loaded"
