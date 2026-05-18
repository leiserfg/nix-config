#!/usr/bin/env python3
"""
Read and print Hyprland events from the socket using asyncio.
"""

import asyncio
import json
import math
import os
import sys
from dataclasses import dataclass, fields
from functools import cached_property, wraps
from pathlib import Path

# Constants
WAYLAND_SCALE_STEP = 120  # Wayland fractional-scale protocol uses 1/120 increments
SCALE_SEARCH_RANGE = 90  # Search ±90 increments (±0.75) from target scale

# Scale tuning constants
MIN_SCALE = 1
MAX_SCALE = 4
STEPS = 8  # 0.125 increments
MIN_LOGICAL_AREA = 800 * 480

# Map from minimum diagonal size (in inches) to a target DPI used to compute
# the 'perfect' scale. This allows tuning how aggressively large monitors are
# scaled. The list should be ordered by increasing min_diagonal.
# Example: (0, 135) means for any screen >= 0" use 135 DPI target; (20,185)
# means for screens >= 20" use 185 DPI target.
SIZE_TO_TARGET_DPI = [
    (0.0, 135.0),  # phones / laptops
    (15.0, 150.0),  # medium monitors -> tuned to prefer ~1.5 scale
    (27.0, 242.0),  # DELL S2721QS (27") -> tuned to prefer ~1.5 scale
    (30.0, 185.0),  # ultrawide monitors -> tuned to prefer ~1.66 for the ultrawide
]


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

    # First, round to 1/WAYLAND_SCALE_STEP increments
    search_scale = round(target_scale * WAYLAND_SCALE_STEP)
    scale_zero = search_scale / WAYLAND_SCALE_STEP

    logical_width = width / scale_zero
    logical_height = height / scale_zero

    # Check if close enough to whole pixels (within 0.01)
    if (
        abs(logical_width - round(logical_width)) < 0.01
        and abs(logical_height - round(logical_height)) < 0.01
    ):
        return scale_zero

    # Search for nearest valid scale within ±SCALE_SEARCH_RANGE increments
    # Check both directions at the same offset and prefer the one closest to the
    # original target_scale. This avoids always preferring the higher scale
    # (which could return 2.0 for 1.66-like targets).
    for i in range(1, SCALE_SEARCH_RANGE):
        scale_up = (search_scale + i) / WAYLAND_SCALE_STEP
        scale_down = (search_scale - i) / WAYLAND_SCALE_STEP

        found_up = False
        found_down = False

        # Try higher scale
        logical_up_w = width / scale_up
        logical_up_h = height / scale_up
        if (
            abs(logical_up_w - round(logical_up_w)) < 0.01
            and abs(logical_up_h - round(logical_up_h)) < 0.01
        ):
            found_up = True

        # Try lower scale (ensure positive)
        if scale_down > 0:
            logical_down_w = width / scale_down
            logical_down_h = height / scale_down
            if (
                abs(logical_down_w - round(logical_down_w)) < 0.01
                and abs(logical_down_h - round(logical_down_h)) < 0.01
            ):
                found_down = True
        # If both directions are valid, choose the one closer to the original target
        if found_up and found_down:
            # Compare distance to the (unrounded) target_scale passed in
            if abs(scale_up - target_scale) <= abs(scale_down - target_scale):
                return scale_up
            else:
                return scale_down
        elif found_up:
            return scale_up
        elif found_down:
            return scale_down

    return scale_zero


def calculate_scale(
    width: int,
    height: int,
    physical_width_mm: float | None,
    physical_height_mm: float | None,
) -> float:
    """
    Pure calculation of the preferred scale for a monitor given its pixel
    resolution and physical dimensions (in millimetres).

    This encapsulates the algorithm for computing optimal display scale and
    returns the finalized scale value (validated to prefer whole logical pixels
    when possible).

    Args:
        width: pixel width
        height: pixel height
        physical_width_mm: physical width in millimetres
        physical_height_mm: physical height in millimetres

    Returns:
        float preferred scale

    Examples (doctest):

    >>> # 1920x1200, 300x190 mm => should be about 1.20
    >>> round(calculate_scale(1920, 1200, 300, 190), 2)
    1.2

    >>> # 3440x1440, 800x330 mm => expected approx 1.67
    >>> round(calculate_scale(3440, 1440, 800, 330), 2)
    1.67

    """
    # If physical size is missing or invalid, default to 1.0
    if (
        not physical_width_mm
        or not physical_height_mm
        or physical_width_mm <= 0
        or physical_height_mm <= 0
    ):
        return 1.0

    # Compute diagonal size in inches
    diag_inches = ((physical_width_mm**2 + physical_height_mm**2) ** 0.5) / 25.4

    # Lookup target DPI from SIZE_TO_TARGET_DPI table. Use the largest entry where
    # min_diag <= diag_inches.
    target_dpi = SIZE_TO_TARGET_DPI[0][1]
    for min_diag, dpi in SIZE_TO_TARGET_DPI:
        if diag_inches >= min_diag:
            target_dpi = dpi
        else:
            break

    # Use vertical DPI for scaling
    physical_height_in = physical_height_mm / 25.4
    vertical_dpi = height / physical_height_in
    physical_dpi = vertical_dpi

    # Calculate the 'perfect' (ideal) scale. We keep the same logic as before
    # where small screens scale as physical/target while large screens invert
    # (target/physical). Since target_dpi is now tunable per size, this produces
    # different results depending on SIZE_TO_TARGET_DPI.
    if diag_inches < SIZE_TO_TARGET_DPI[1][0]:
        perfect_scale = physical_dpi / target_dpi
    else:
        perfect_scale = target_dpi / physical_dpi

    # Candidate integer-producing scales using gcd method
    g = math.gcd(width, height)
    candidates = []

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

        logical_w = int(width / scale_candidate)
        logical_h = int(height / scale_candidate)
        if logical_w * logical_h >= MIN_LOGICAL_AREA:
            candidates.append(scale_candidate)

    if candidates:
        best_candidate = min(candidates, key=lambda s: abs(s - perfect_scale))
        best_candidate = closest_representable_scale(best_candidate)
        best_scale = best_candidate
    else:
        supported_scales = []
        for i in range(MIN_SCALE * STEPS, MAX_SCALE * STEPS + 1):
            scale = i / STEPS
            logical_width = int(width / scale)
            logical_height = int(height / scale)
            logical_area = logical_width * logical_height
            if logical_area >= MIN_LOGICAL_AREA:
                supported_scales.append(scale)

        if not supported_scales:
            return 1.0

        best_scale = min(supported_scales, key=lambda s: abs(s - perfect_scale))

    # Validate to prefer whole logical pixels
    def _find_valid_scale(w: int, h: int, target: float) -> float:
        search_scale = round(target * WAYLAND_SCALE_STEP)
        scale_zero = search_scale / WAYLAND_SCALE_STEP

        logical_width = w / scale_zero
        logical_height = h / scale_zero

        if (
            abs(logical_width - round(logical_width)) < 0.01
            and abs(logical_height - round(logical_height)) < 0.01
        ):
            return scale_zero

        for i in range(1, SCALE_SEARCH_RANGE):
            scale_up = (search_scale + i) / WAYLAND_SCALE_STEP
            scale_down = (search_scale - i) / WAYLAND_SCALE_STEP

            found_up = False
            found_down = False

            logical_up_w = w / scale_up
            logical_up_h = h / scale_up
            if (
                abs(logical_up_w - round(logical_up_w)) < 0.01
                and abs(logical_up_h - round(logical_up_h)) < 0.01
            ):
                found_up = True

            if scale_down > 0:
                logical_down_w = w / scale_down
                logical_down_h = h / scale_down
                if (
                    abs(logical_down_w - round(logical_down_w)) < 0.01
                    and abs(logical_down_h - round(logical_down_h)) < 0.01
                ):
                    found_down = True

            if found_up and found_down:
                if abs(scale_up - target) <= abs(scale_down - target):
                    return scale_up
                else:
                    return scale_down
            elif found_up:
                return scale_up
            elif found_down:
                return scale_down

        return scale_zero

    valid_scale = _find_valid_scale(width, height, best_scale)
    return valid_scale


@dataclass(kw_only=True, slots=True)
class ModeInfo:
    """Best mode information with width, height, refresh rate, and full mode string."""

    width: int
    height: int
    mode_string: str
    refresh_rate: float = 0.0


def parse_mode(mode_str: str) -> ModeInfo | None:
    """Parse mode string and return ModeInfo."""
    try:
        resolution, rate_part = mode_str.split("@")
        width, height = map(int, resolution.split("x"))
        refresh_rate = float(rate_part.replace("Hz", ""))
        return ModeInfo(
            width=width,
            height=height,
            mode_string=mode_str,
            refresh_rate=refresh_rate,
        )
    except (ValueError, IndexError):
        return None


@dataclass(kw_only=True)
class Monitor:
    """Hyprland monitor info."""

    name: str
    description: str
    refreshRate: float
    physicalWidth: int
    physicalHeight: int
    disabled: bool
    availableModes: list[str]
    width: int = 0  # Current mode width
    height: int = 0  # Current mode height
    scale: float

    @cached_property
    def best_mode(self) -> ModeInfo | None:
        """Get the best available mode based on highest height, then highest rate.

        Returns:
            ModeInfo with width, height, and full mode string, or None if no modes available.
        """
        if not self.availableModes:
            return None

        # Parse all modes, filtering out malformed ones
        parsed_modes = (
            parse_mode(m) for m in self.availableModes if parse_mode(m) is not None
        )

        # Get best mode by height (desc), then rate (desc)
        best = max(
            parsed_modes,
            key=lambda m: (m.height, m.refresh_rate),
            default=None,
        )

        return best

    async def set_rule(
        self,
    ):
        """Apply monitor configuration rule using the best available mode.

        Compares best mode settings and calculated scale against current monitor
        configuration. Only applies the rule if there's a mismatch.

        Returns:
            bool indicating success
        """
        if not self.best_mode:
            return

        # Calculate the best scale using best_mode and physical dimensions
        calculated_scale = calculate_scale(
            width=self.best_mode.width,
            height=self.best_mode.height,
            physical_width_mm=self.physicalWidth,
            physical_height_mm=self.physicalHeight,
        )

        # Check if best_mode (width, height, rate) and calculated scale match current settings
        needs_update = (
            self.best_mode.width != self.width
            or self.best_mode.height != self.height
            or self.best_mode.refresh_rate != self.refreshRate
            or calculated_scale != self.scale
        )

        # Only apply if there's a mismatch
        if needs_update:
            await apply_monitor_rule(
                output=self.name,
                disabled=False,
                scale=calculated_scale,
                mode=self.best_mode.mode_string,
            )


def async_debounce(wait):
    def decorator(func):
        task = None

        @wraps(func)
        async def debounced(*args, **kwargs):
            nonlocal task

            async def call_func():
                await asyncio.sleep(wait)
                await func(*args, **kwargs)

            if task and not task.done():
                task.cancel()

            task = asyncio.create_task(call_func())
            return task

        return debounced

    return decorator


def to_lua(d: dict) -> str:
    """Convert a Python dict to a Lua table expression string.

    Keys are strings. Values can be strings, bools, numbers, and None.
    None values are skipped. Other types raise TypeError.
    Returns a string representing the Lua equivalent expression.

    Example:
        >>> to_lua({"a": 1, "b": "hello", "c": True, "d": None})
        '{a = 1, b = "hello", c = true}'
    """
    items = []
    for key, value in d.items():
        if value is None:
            continue
        elif isinstance(value, bool):
            lua_value = "true" if value else "false"
        elif isinstance(value, (int, float)):
            lua_value = str(value)
        elif isinstance(value, str):
            # Escape quotes and backslashes
            escaped = value.replace("\\", "\\\\").replace("'", "\\'")
            lua_value = f"'{escaped}'"
        else:
            raise TypeError(f"Unsupported value type for key '{key}': {type(value)}")
        items.append(f"{key} = {lua_value}")
    return "{" + ", ".join(items) + "}"


async def apply_monitor_rule(
    output: str,
    disabled: bool = False,
    scale: float = 1.0,
    mode: str | None = None,
) -> bool:
    """Apply monitor configuration rules using Hyprland's monitor command."""
    rule_dict = {
        "output": output,
        "disabled": disabled,
        "scale": scale,
        "position": "auto",
        "mode": mode,
    }
    lua_table = to_lua(rule_dict)
    command = f"eval hl.monitor{lua_table}"
    print(command)
    result = await send_hyprland_command(command)
    print(result)
    return result is not None


@async_debounce(1.0)  # Avoid firing the event too many times
async def setup_monitors() -> None:
    """Handle monitor events (monitoradded/monitorremoved)."""

    await asyncio.sleep(0.2)

    monitors = await get_monitors()
    monitors = (m for m in monitors if m.name != "FALLBACK")
    for m in monitors:
        await m.set_rule()


def parse_monitors(data: list[dict]) -> list[Monitor]:
    """Parse monitor list from JSON response into Monitor dataclass instances."""
    monitor_fields = {f.name for f in fields(Monitor)}
    return [Monitor(**{k: m[k] for k in monitor_fields if k in m}) for m in data]


async def send_hyprland_command(command: str, flags: str = "") -> str | None:
    """Send a command to Hyprland IPC socket and return response string.

    Message format: [flag(s)]/command args
    Example: [j]/monitors all
    """
    xdg_runtime_dir = os.getenv("XDG_RUNTIME_DIR")
    if not xdg_runtime_dir:
        print("Error: XDG_RUNTIME_DIR not set", file=sys.stderr)
        return None

    hypr_instance = os.getenv("HYPRLAND_INSTANCE_SIGNATURE")
    if not hypr_instance:
        print(
            "Error: HYPRLAND_INSTANCE_SIGNATURE not set. Are you running Hyprland?",
            file=sys.stderr,
        )
        return None

    socket_path = Path(xdg_runtime_dir) / "hypr" / hypr_instance / ".socket.sock"

    if not socket_path.exists():
        print(f"Error: Hyprland socket not found at {socket_path}", file=sys.stderr)
        return None

    try:
        reader, writer = await asyncio.open_unix_connection(str(socket_path))

        # Format: [flag(s)]/command
        message = f"[{flags}]/{command}\n"
        writer.write(message.encode())
        await writer.drain()

        # Read the response
        response = await reader.read(4096)
        writer.close()
        await writer.wait_closed()

        if not response:
            print("Error: Empty response from Hyprland socket", file=sys.stderr)
            return None

        return response.decode().strip()

    except ConnectionRefusedError:
        print(
            f"Error: Could not connect to Hyprland socket at {socket_path}",
            file=sys.stderr,
        )
        return None
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return None


async def get_monitors() -> list[Monitor] | None:
    """Get all active monitors"""
    response = await send_hyprland_command("monitors", flags="j")
    if response is None:
        return None
    try:
        data = json.loads(response)
        return parse_monitors(data)
    except json.JSONDecodeError as e:
        print(f"Error: Failed to parse JSON response: {e}", file=sys.stderr)
        return None


def parse_event(event: str) -> tuple[str, list[str]] | None:
    """Parse event in format 'name>>args' and return (name, args)."""
    if ">>" not in event:
        return None
    name, args = event.split(">>", 1)
    return (name, args.split(","))


async def read_hyprland_events():
    """Connect to Hyprland socket and read events."""

    # Get the Hyprland socket path
    xdg_runtime_dir = os.getenv("XDG_RUNTIME_DIR")
    if not xdg_runtime_dir:
        print("Error: XDG_RUNTIME_DIR not set", file=sys.stderr)
        return

    hypr_instance = os.getenv("HYPRLAND_INSTANCE_SIGNATURE")
    if not hypr_instance:
        print(
            "Error: HYPRLAND_INSTANCE_SIGNATURE not set. Are you running Hyprland?",
            file=sys.stderr,
        )
        return

    socket_path = Path(xdg_runtime_dir) / "hypr" / hypr_instance / ".socket2.sock"

    if not socket_path.exists():
        print(f"Error: Hyprland socket not found at {socket_path}", file=sys.stderr)
        return

    print(f"Connecting to Hyprland socket: {socket_path}")
    print("Listening for events (Ctrl+C to stop)...\n")
    await setup_monitors()
    try:
        # Create a connection to the Unix socket
        reader, _ = await asyncio.open_unix_connection(str(socket_path))

        print("Reading Hyprland events...")

        # Read events
        while True:
            try:
                # Read a line from the socket
                line = await reader.readline()

                if not line:
                    print("Connection closed by Hyprland", file=sys.stderr)
                    break

                # Decode and parse the event
                event = line.decode().strip()
                if event:
                    parsed = parse_event(event)
                    if parsed:
                        name, args = parsed
                        if name in ("monitoradded", "configreloaded"):
                            await setup_monitors()

            except asyncio.CancelledError:
                break

    except ConnectionRefusedError:
        print(
            f"Error: Could not connect to Hyprland socket at {socket_path}",
            file=sys.stderr,
        )
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)


async def main():
    """Main entry point."""
    try:
        await read_hyprland_events()
    except KeyboardInterrupt:
        print("\nShutting down...")
        sys.exit(0)


if __name__ == "__main__":
    asyncio.run(main())
