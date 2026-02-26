#!/usr/bin/env python3
"""
Hyprland Monitor Manager
Automatically manages monitor configuration:
- Sets optimal scale for eDP-1 (laptop screen) on startup
- Disables eDP-1 when external monitors are connected
- Re-enables eDP-1 when it's the only monitor remaining
"""

import socket
import json
import subprocess
import os
import sys
import time
import re
from typing import NamedTuple, Optional


# Constants
WAYLAND_SCALE_STEP = 120  # Wayland fractional-scale protocol uses 1/120 increments
SCALE_SEARCH_RANGE = 90  # Search ±90 increments (±0.75) from target scale
SOCKET_TIMEOUT = 5.0  # Socket timeout in seconds
SOCKET_BUFFER_SIZE = 8192  # Buffer size for socket receive
EVENT_DEBOUNCE_DELAY = 0.5  # Debounce delay for monitor events in seconds


class MonitorMode(NamedTuple):
    """Monitor resolution and refresh rate information"""

    width: int
    height: int
    refresh_rate: float


class MonitorConfig(NamedTuple):
    """Monitor physical and logical configuration"""

    width: int
    height: int
    physical_width_mm: Optional[float]
    physical_height_mm: Optional[float]


class MonitorRule(NamedTuple):
    """Hyprland monitor rule with metadata"""

    name: str
    desc: str
    rule: str
    width: int
    height: int
    refresh: float
    scale: float


def hyprland_get_monitors(all_monitors: bool = False) -> Optional[list]:
    """Get list of monitors (including disabled ones if all_monitors=True)"""
    command = "monitors all" if all_monitors else "monitors"
    try:
        result = subprocess.run(
            ["hyprctl", "-j"] + command.split(),
            capture_output=True,
            text=True,
            check=True,
        )

        monitors = json.loads(result.stdout)
        if any(m["name"].lower() == "fallback" for m in monitors):
            sys.exit(1)
        return monitors

    except subprocess.CalledProcessError as e:
        print(f"Error running hyprctl: {e}", file=sys.stderr)
        return None
    except json.JSONDecodeError as e:
        print(f"Error parsing hyprctl output: {e}", file=sys.stderr)
        return None


def hyprland_set_rule(rule_command: str) -> bool:
    """Execute hyprctl keyword command to set a rule. Returns True on success."""
    try:
        subprocess.run(
            ["hyprctl", "keyword"] + rule_command.split(),
            capture_output=True,
            text=True,
            check=True,
        )
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error running hyprctl keyword: {e}", file=sys.stderr)
        return False


def closest_representable_scale(scale: float) -> float:
    """
    Adjusts the scale to the closest exactly-representable value.
    Hyprland uses 1/120 increments (like the Wayland fractional-scale protocol).
    """
    # Round to nearest 1/WAYLAND_SCALE_STEP
    return round(scale * WAYLAND_SCALE_STEP) / WAYLAND_SCALE_STEP


def find_valid_scale_for_resolution(
    width: int, height: int, target_scale: float
) -> float:
    """
    Find a valid scale, preferring ones that produce whole logical pixels.
    Falls back to the target scale if no perfect match is found.
    """
    print(f"  DEBUG find_valid_scale: input target_scale={target_scale}")

    # First, round to 1/WAYLAND_SCALE_STEP increments
    search_scale = round(target_scale * WAYLAND_SCALE_STEP)
    scale_zero = search_scale / WAYLAND_SCALE_STEP

    print(
        f"  DEBUG find_valid_scale: search_scale={search_scale}, scale_zero={scale_zero}"
    )

    logical_width = width / scale_zero
    logical_height = height / scale_zero

    print(
        f"  DEBUG find_valid_scale: logical resolution would be {logical_width}x{logical_height}"
    )
    print(
        f"  DEBUG find_valid_scale: differences from whole: w={abs(logical_width - round(logical_width)):.6f}, h={abs(logical_height - round(logical_height)):.6f}"
    )

    # Check if close enough to whole pixels (within 0.01)
    if (
        abs(logical_width - round(logical_width)) < 0.01
        and abs(logical_height - round(logical_height)) < 0.01
    ):
        print(
            f"  DEBUG find_valid_scale: scale_zero passes tolerance check, returning {scale_zero}"
        )
        return scale_zero

    print(
        f"  DEBUG find_valid_scale: scale_zero failed tolerance check, searching nearby scales..."
    )

    # Search for nearest valid scale within ±SCALE_SEARCH_RANGE increments
    for i in range(1, SCALE_SEARCH_RANGE):
        scale_up = (search_scale + i) / WAYLAND_SCALE_STEP
        scale_down = (search_scale - i) / WAYLAND_SCALE_STEP

        # Try higher scale
        logical_up_w = width / scale_up
        logical_up_h = height / scale_up
        if (
            abs(logical_up_w - round(logical_up_w)) < 0.01
            and abs(logical_up_h - round(logical_up_h)) < 0.01
        ):
            print(
                f"  DEBUG find_valid_scale: found valid scale_up={scale_up} at offset {i}"
            )
            return scale_up

        # Try lower scale
        logical_down_w = width / scale_down
        logical_down_h = height / scale_down
        if (
            abs(logical_down_w - round(logical_down_w)) < 0.01
            and abs(logical_down_h - round(logical_down_h)) < 0.01
        ):
            print(
                f"  DEBUG find_valid_scale: found valid scale_down={scale_down} at offset {i}"
            )
            return scale_down

    # If no perfect scale found, just use the rounded scale anyway
    # Hyprland can handle fractional logical pixels in practice
    print(f"  Note: Using scale {scale_zero} (produces fractional logical pixels)")
    print(
        f"  DEBUG find_valid_scale: no perfect match found, returning scale_zero={scale_zero}"
    )
    return scale_zero


def guess_monitor_scale(config: MonitorConfig) -> float:
    """
    Calculate the best scale factor based on resolution and physical size.
    Based on niri's algorithm (which follows Mutter's logic):
    https://github.com/niri-wm/niri/blob/main/src/utils/scale.rs

    Args:
        config: MonitorConfig with width, height, and physical dimensions

    Returns:
        Float scale factor
    """
    # Constants from niri
    MIN_SCALE = 1
    MAX_SCALE = 4
    STEPS = 8  # 0.125 increments
    MIN_LOGICAL_AREA = 800 * 480

    MOBILE_TARGET_DPI = 135.0
    LARGE_TARGET_DPI = 240.0  # Higher target for large monitors = bigger UI elements
    LARGE_MIN_SIZE_INCHES = 20.0

    width = config.width
    height = config.height
    physical_width_mm = config.physical_width_mm
    physical_height_mm = config.physical_height_mm

    # Default to scale 1.0 if no physical size
    if (
        not physical_width_mm
        or not physical_height_mm
        or physical_width_mm <= 0
        or physical_height_mm <= 0
    ):
        print("  Physical size unknown, defaulting to scale 1.0")
        return 1.0

    print(f"  Physical size: {physical_width_mm}x{physical_height_mm}mm")

    # Calculate diagonal in inches
    diag_inches = ((physical_width_mm**2 + physical_height_mm**2) ** 0.5) / 25.4
    print(f"  Diagonal: {diag_inches:.1f} inches")

    # Choose target DPI based on screen size
    # Smaller screens (< 20") use mobile target DPI
    # Larger screens use HIGHER target DPI because they're typically viewed from farther away
    # Higher target DPI / lower physical DPI = larger scale = bigger UI
    if diag_inches < LARGE_MIN_SIZE_INCHES:
        target_dpi = MOBILE_TARGET_DPI
        print(f"  Target DPI: {target_dpi} (mobile/laptop)")
    else:
        target_dpi = LARGE_TARGET_DPI
        print(f"  Target DPI: {target_dpi} (large monitor, viewed from distance)")

    # Calculate actual physical DPI — use vertical DPI for UI scaling
    physical_width_in = physical_width_mm / 25.4
    physical_height_in = physical_height_mm / 25.4
    horizontal_dpi = width / physical_width_in
    vertical_dpi = height / physical_height_in
    physical_dpi = vertical_dpi
    print(
        f"  Physical DPI (horizontal x vertical): {horizontal_dpi:.1f} x {vertical_dpi:.1f}"
    )
    print(f"  Using vertical DPI ({physical_dpi:.1f}) for scale calculation")

    # Calculate perfect scale
    # For large monitors viewed from distance, we want LARGER UI elements
    # So we scale UP when physical DPI is low
    if diag_inches < LARGE_MIN_SIZE_INCHES:
        # Small screens: scale based on mobile target (higher DPI = larger scale)
        perfect_scale = physical_dpi / target_dpi
        print(f"  Perfect scale: {perfect_scale:.3f} (small screen: physical/target)")
    else:
        # Large screens: invert the logic - lower physical DPI = larger scale
        # We want to achieve the mobile target DPI at the logical level
        perfect_scale = target_dpi / physical_dpi
        print(
            f"  Perfect scale: {perfect_scale:.3f} (large screen: target/physical, viewed from distance)"
        )

    # Generate candidate exact integer-producing scales using gcd method
    # scale = g / t  where g = gcd(width, height) and t is a positive integer
    # We prefer candidates that are representable by the compositor (1/WAYLAND_SCALE_STEP)
    import math

    g = math.gcd(width, height)
    candidates = []

    # t range so that scale in [MIN_SCALE, MAX_SCALE]
    t_min = max(1, math.ceil(g / MAX_SCALE))
    t_max = max(1, math.floor(g / MIN_SCALE))

    for t in range(t_min, t_max + 1):
        scale_candidate = g / t

        # Must be representable by compositor increments (1/WAYLAND_SCALE_STEP)
        if (
            abs(
                round(scale_candidate * WAYLAND_SCALE_STEP)
                - scale_candidate * WAYLAND_SCALE_STEP
            )
            > 1e-9
        ):
            continue

        # Check logical area constraint
        logical_w = int(width / scale_candidate)
        logical_h = int(height / scale_candidate)
        if logical_w * logical_h >= MIN_LOGICAL_AREA:
            candidates.append(scale_candidate)

    if candidates:
        # Pick the candidate closest to perfect_scale
        best_candidate = min(candidates, key=lambda s: abs(s - perfect_scale))
        best_candidate = closest_representable_scale(best_candidate)
        print(f"  Integer-producing representable candidates: {candidates}")
        print(
            f"  Selected integer-producing candidate: {best_candidate} (closest to perfect {perfect_scale:.3f})"
        )
        best_scale = best_candidate
    else:
        # Fallback: generate all supported UI scales and pick closest
        supported_scales = []
        for i in range(MIN_SCALE * STEPS, MAX_SCALE * STEPS + 1):
            scale = i / STEPS

            # Check if this scale gives enough logical area
            logical_width = int(width / scale)
            logical_height = int(height / scale)
            logical_area = logical_width * logical_height

            if logical_area >= MIN_LOGICAL_AREA:
                supported_scales.append(scale)

        if not supported_scales:
            print("  No supported scales found, defaulting to 1.0")
            return 1.0

        # Find the scale closest to perfect_scale
        best_scale = min(supported_scales, key=lambda s: abs(s - perfect_scale))

        print(f"  Supported scales: {supported_scales}")
        print(f"  Selected scale: {best_scale}")

    # DEBUG: Print what we're about to validate
    print(f"  DEBUG: About to validate scale {best_scale} for {width}x{height}")
    print(
        f"  DEBUG: This would give logical resolution: {width / best_scale:.2f}x{height / best_scale:.2f}"
    )

    # Validate and adjust scale to produce whole logical pixels (Hyprland requirement)
    valid_scale = find_valid_scale_for_resolution(width, height, best_scale)

    print(f"  DEBUG: Validation returned scale: {valid_scale}")

    if valid_scale != best_scale:
        print(
            f"  Adjusted to valid scale: {valid_scale} (produces whole logical pixels)"
        )

    return valid_scale


def get_monitor_info(monitor_name: str) -> Optional[dict]:
    """Get monitor information by name (including disabled ones)"""
    monitors = hyprland_get_monitors(all_monitors=True)
    if not monitors:
        print(
            f"Warning: No monitors found when looking for {monitor_name}",
            file=sys.stderr,
        )
        return None

    for monitor in monitors:
        if monitor.get("name") == monitor_name:
            return monitor

    print(f"Warning: Monitor {monitor_name} not found in monitor list", file=sys.stderr)
    return None


def get_best_mode_for_monitor(monitor_name: str) -> Optional[MonitorMode]:
    """
    Get the best resolution and refresh rate for a monitor.
    Prefers highest resolution with refresh rate >= 60Hz.
    Falls back to highest resolution if no 60Hz+ mode available.

    Returns:
        MonitorMode with width, height, and refresh_rate, or None on error.
    """
    try:
        result = subprocess.run(
            ["hyprctl", "-j", "monitors", "all"],
            capture_output=True,
            text=True,
            check=True,
        )
        monitors = json.loads(result.stdout)

        monitor = None
        for m in monitors:
            if m.get("name") == monitor_name:
                monitor = m
                break

        if not monitor:
            return None

        available_modes = monitor.get("availableModes", [])
        if not available_modes:
            # Fallback to current mode
            return MonitorMode(
                width=monitor.get("width", 1920),
                height=monitor.get("height", 1080),
                refresh_rate=monitor.get("refreshRate", 60.0),
            )

        # Parse available modes and find the best one
        # Format is like "1920x1080@60.00Hz"
        modes = []
        mode_pattern = re.compile(r"(\d+)x(\d+)@([\d.]+)Hz")

        for mode_str in available_modes:
            match = mode_pattern.search(mode_str)
            if match:
                width = int(match.group(1))
                height = int(match.group(2))
                refresh = float(match.group(3))
                modes.append(MonitorMode(width, height, refresh))

        if not modes:
            # Fallback to current mode
            return MonitorMode(
                width=monitor.get("width", 1920),
                height=monitor.get("height", 1080),
                refresh_rate=monitor.get("refreshRate", 60.0),
            )

        # Filter modes with > 59Hz, sometimes bad cables limit it to 30Hz and that sucks, I use 59 cause some monitors use fractinal rates
        high_refresh_modes = [m for m in modes if m.refresh_rate > 59.0]

        if high_refresh_modes:
            # Pick highest resolution among high refresh modes
            # Sort by total pixels (width * height), then by refresh rate
            best_mode = max(
                high_refresh_modes, key=lambda m: (m.width * m.height, m.refresh_rate)
            )
        else:
            # No 60Hz+ modes, just pick highest resolution
            best_mode = max(modes, key=lambda m: (m.width * m.height, m.refresh_rate))

        return best_mode

    except (subprocess.CalledProcessError, json.JSONDecodeError, KeyError):
        return None


def create_ideal_monitor_rule(monitor_name: str) -> Optional[MonitorRule]:
    """Create and store the ideal rule for any monitor"""
    monitor = get_monitor_info(monitor_name)
    if not monitor:
        print(f"{monitor_name} not found!", file=sys.stderr)
        return None

    print(f"  Found monitor: {monitor_name}")
    print(f"  Current state: {monitor}")

    # Get monitor description
    desc = monitor.get("description", "")
    if not desc:
        print(f"  Warning: No description for {monitor_name}", file=sys.stderr)
        desc = monitor_name  # Fallback to name

    print(f"  Description: {desc}")

    # Get the best mode (resolution and refresh rate)
    mode = get_best_mode_for_monitor(monitor_name)
    if mode:
        width, height, refresh = mode.width, mode.height, mode.refresh_rate
        print(f"  Selected mode: {width}x{height}@{refresh:.0f}Hz")
    else:
        # Fallback to current settings
        width = monitor.get("width", 1920)
        height = monitor.get("height", 1080)
        refresh = monitor.get("refreshRate", 60.0)
        print(f"  Using current mode: {width}x{height}@{refresh:.0f}Hz")

    # Try to get physical dimensions (in mm)
    physical_width_mm = monitor.get("physicalWidth")
    physical_height_mm = monitor.get("physicalHeight")

    # Create monitor config and get the best scale
    config = MonitorConfig(
        width=width,
        height=height,
        physical_width_mm=physical_width_mm,
        physical_height_mm=physical_height_mm,
    )
    scale = guess_monitor_scale(config)

    # Create the monitor rule using desc instead of name
    rule = f"monitor desc:{desc},{width}x{height}@{refresh:.0f},auto,{scale}"

    print(f"Calculated ideal {monitor_name} rule: {rule}")
    print(f"  Resolution: {width}x{height}")
    print(f"  Refresh rate: {refresh:.0f}Hz")
    print(f"  Scale: {scale}")

    return MonitorRule(
        name=monitor_name,
        desc=desc,
        rule=rule,
        width=width,
        height=height,
        refresh=refresh,
        scale=scale,
    )


def apply_monitor_rule(monitor_rule: MonitorRule) -> bool:
    """Apply a monitor rule. Returns True on success."""
    if not monitor_rule:
        print("No monitor rule to apply!", file=sys.stderr)
        return False

    print(f"Applying rule: {monitor_rule.rule}")
    return hyprland_set_rule(monitor_rule.rule)


def configure_all_external_monitors(monitor_rules_cache: dict) -> None:
    """Configure all external monitors (non-eDP-1) with optimal settings"""
    monitors = hyprland_get_monitors(all_monitors=True)
    if not monitors:
        return

    external_monitors = [
        m for m in monitors if m["name"] != "eDP-1" and not m.get("disabled", True)
    ]

    for monitor in external_monitors:
        monitor_name = monitor["name"]
        monitor_desc = monitor.get("description", "")

        if not monitor_desc:
            print(
                f"Warning: No description for {monitor_name}, using name as fallback",
                file=sys.stderr,
            )
            monitor_desc = monitor_name

        # Check if we have a cached rule for this monitor description
        if monitor_desc in monitor_rules_cache:
            print(f"\nUsing cached rule for {monitor_name} (desc: {monitor_desc})")
            rule = monitor_rules_cache[monitor_desc]
        else:
            print(
                f"\nConfiguring external monitor: {monitor_name} (desc: {monitor_desc})"
            )
            rule = create_ideal_monitor_rule(monitor_name)
            if rule:
                monitor_rules_cache[monitor_desc] = rule
                print(f"Cached rule for desc: {monitor_desc}")

        if rule:
            apply_monitor_rule(rule)


def disable_edp1() -> None:
    """Disable eDP-1 monitor"""
    print("Disabling eDP-1...")
    hyprland_set_rule("monitor eDP-1,disable")


def enable_edp1(ideal_rule: Optional[MonitorRule]) -> None:
    """Enable eDP-1 with ideal rule"""
    if not ideal_rule:
        print("No ideal rule stored for eDP-1!", file=sys.stderr)
        return

    print(f"Enabling eDP-1 with rule: {ideal_rule.rule}")
    hyprland_set_rule(ideal_rule.rule)


def get_active_monitor_names() -> list[str]:
    """Get list of active monitor names (excluding disabled monitors)"""
    monitors = hyprland_get_monitors()
    if not monitors:
        return []
    return [m["name"] for m in monitors if not m.get("disabled", False)]


def get_hyprland_socket_path() -> str:
    """Get the Hyprland event socket path"""
    instance_sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if not instance_sig:
        print("HYPRLAND_INSTANCE_SIGNATURE not found in environment!", file=sys.stderr)
        sys.exit(1)

    runtime_dir = os.environ.get("XDG_RUNTIME_DIR", "/run/user/1000")
    socket_path = f"{runtime_dir}/hypr/{instance_sig}/.socket2.sock"
    return socket_path


def print_cache(monitor_rules_cache: dict) -> None:
    """Print the current cache contents"""
    print(f"\n=== Monitor Rules Cache ({len(monitor_rules_cache)} entries) ===")
    if not monitor_rules_cache:
        print("  (empty)")
    else:
        for desc, rule in monitor_rules_cache.items():
            print(f"  - {desc[:60]}{'...' if len(desc) > 60 else ''}")
            print(
                f"    -> {rule.name}: {rule.width}x{rule.height}@{rule.refresh:.0f}Hz, scale={rule.scale}"
            )
    print("=" * 50 + "\n")


def listen_to_events(
    ideal_edp1_rule: Optional[MonitorRule], monitor_rules_cache: dict
) -> None:
    """Listen to Hyprland events and manage monitors"""
    socket_path = get_hyprland_socket_path()

    print(f"Connecting to Hyprland socket: {socket_path}")

    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(SOCKET_TIMEOUT)

    try:
        sock.connect(socket_path)
    except (ConnectionRefusedError, FileNotFoundError) as e:
        print(f"Failed to connect to Hyprland socket: {e}", file=sys.stderr)
        sys.exit(1)

    print("Connected! Listening for monitor events...")

    buffer = ""

    try:
        while True:
            try:
                data = sock.recv(SOCKET_BUFFER_SIZE).decode("utf-8")
                if not data:
                    print("Socket connection closed by server", file=sys.stderr)
                    break

                buffer += data

                # Process complete events (separated by newlines)
                while "\n" in buffer:
                    line, buffer = buffer.split("\n", 1)

                    if not line:
                        continue

                    # Events are in format: EVENT>>DATA
                    if ">>" not in line:
                        continue

                    event_type, event_data = line.split(">>", 1)

                    # Monitor added event
                    if event_type == "monitoradded":
                        monitor_name = event_data.strip()
                        print(f"\n[EVENT] Monitor added: {monitor_name}")

                        if monitor_name != "eDP-1":
                            # External monitor connected
                            # Debounce to allow monitor to be fully initialized
                            time.sleep(EVENT_DEBOUNCE_DELAY)

                            # Get monitor info to retrieve description
                            monitor_info = get_monitor_info(monitor_name)
                            if not monitor_info:
                                print(f"Warning: Could not get info for {monitor_name}")
                                continue

                            monitor_desc = monitor_info.get("description", "")
                            if not monitor_desc:
                                print(
                                    f"Warning: No description for {monitor_name}, using name as fallback",
                                    file=sys.stderr,
                                )
                                monitor_desc = monitor_name

                            # Check if we have a cached rule for this monitor description
                            if monitor_desc in monitor_rules_cache:
                                print(
                                    f"Using cached rule for {monitor_name} (desc: {monitor_desc})"
                                )
                                external_rule = monitor_rules_cache[monitor_desc]
                            else:
                                # Create and cache the rule
                                print(
                                    f"Creating new rule for {monitor_name} (desc: {monitor_desc})"
                                )
                                external_rule = create_ideal_monitor_rule(monitor_name)
                                if external_rule:
                                    monitor_rules_cache[monitor_desc] = external_rule
                                    print(f"Cached rule for desc: {monitor_desc}")

                            # Apply the rule
                            if external_rule:
                                apply_monitor_rule(external_rule)
                                # Wait for configuration to apply
                                time.sleep(0.2)
                            else:
                                print(
                                    f"Warning: Could not create rule for {monitor_name}"
                                )

                            # Disable eDP-1 after external monitor is configured
                            active_monitors = get_active_monitor_names()
                            print(f"Active monitors: {active_monitors}")

                            if "eDP-1" in active_monitors:
                                disable_edp1()

                            # Print cache after monitor added
                            print_cache(monitor_rules_cache)
                        else:
                            # eDP-1 was added (shouldn't normally happen)
                            print("eDP-1 reconnected")

                    # Monitor removed event
                    elif event_type == "monitorremoved":
                        monitor_name = event_data.strip()
                        print(f"\n[EVENT] Monitor removed: {monitor_name}")

                        if monitor_name != "eDP-1":
                            # External monitor disconnected
                            # Debounce to ensure monitor is fully removed
                            time.sleep(EVENT_DEBOUNCE_DELAY)

                            active_monitors = get_active_monitor_names()
                            print(f"Active monitors: {active_monitors}")

                            # If only eDP-1 remains (or no monitors), enable it
                            if not active_monitors or active_monitors == ["eDP-1"]:
                                print(
                                    "No external monitors remaining, re-enabling eDP-1"
                                )
                                enable_edp1(ideal_edp1_rule)

                            # Print cache after monitor removed
                            print_cache(monitor_rules_cache)

            except socket.timeout:
                # Timeout is normal, just continue listening
                continue
            except UnicodeDecodeError as e:
                print(f"Error decoding socket data: {e}", file=sys.stderr)
                # Skip this data and continue
                buffer = ""
                continue

    except KeyboardInterrupt:
        print("\nShutting down...")
    finally:
        sock.close()


def main():
    print("=== Hyprland Monitor Manager ===\n")

    # Cache for monitor rules (monitor_desc -> rule)
    monitor_rules_cache = {}

    # Step 1: Calculate ideal eDP-1 rule (using 'monitors all' to get it even if disabled)
    print("Step 1: Calculating optimal configuration for eDP-1...")
    ideal_edp1_rule = create_ideal_monitor_rule("eDP-1")

    if not ideal_edp1_rule:
        print("Failed to get eDP-1 information. Exiting.", file=sys.stderr)
        sys.exit(1)

    # Cache the eDP-1 rule using its description
    monitor_rules_cache[ideal_edp1_rule.desc] = ideal_edp1_rule

    # Step 2: Check current monitor setup and configure all monitors
    print("\nStep 2: Checking current monitor setup...")

    # Always attempt to configure external monitors (this will calculate and apply rules
    # for monitors that are already connected). The function is safe to call if there are
    # no external monitors.
    print("Configuring external monitors with optimal settings (if any)...")
    configure_all_external_monitors(monitor_rules_cache)

    # Re-evaluate active monitors after applying rules
    active_monitors = get_active_monitor_names()
    print(f"Currently active monitors: {active_monitors}")

    # If there are external monitors attached, disable the laptop screen (eDP-1)
    external_monitors = [m for m in active_monitors if m != "eDP-1"]
    if external_monitors:
        print(f"\nExternal monitors detected: {external_monitors}")
        # Only disable eDP-1 if it's currently active
        if "eDP-1" in active_monitors:
            disable_edp1()
        else:
            print("eDP-1 already disabled")
    else:
        # No external monitors, ensure eDP-1 is enabled with ideal settings
        print("No external monitors, enabling eDP-1 with ideal settings")
        enable_edp1(ideal_edp1_rule)

    # Step 3: Listen for events
    print("\nStep 3: Starting event listener...\n")
    print_cache(monitor_rules_cache)
    listen_to_events(ideal_edp1_rule, monitor_rules_cache)


if __name__ == "__main__":
    main()
