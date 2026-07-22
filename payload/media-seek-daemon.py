#!/usr/bin/python3

import json
import subprocess
import time
from pathlib import Path

STATE = Path("/tmp/media-seek")
MEDIA_CONTROL = "/opt/homebrew/bin/media-control"

HOLD_DELAY = 0.0


def active_direction():
    forward = STATE / "forward"
    backward = STATE / "backward"

    if forward.exists():
        return 1, forward

    if backward.exists():
        return -1, backward

    return 0, None


def seek_profile(held_for):
    if held_for < 1.0:
        return 20.0, 0.10

    if held_for < 2.5:
        return 35.0, 0.075

    return 60.0, 0.060


while True:
    direction, state_file = active_direction()

    if direction == 0 or state_file is None:
        time.sleep(0.02)
        continue

    try:
        held_for = time.time() - state_file.stat().st_mtime
    except FileNotFoundError:
        continue

    if held_for < HOLD_DELAY:
        time.sleep(0.01)
        continue

    step, interval = seek_profile(held_for)

    try:
        output = subprocess.check_output(
            [MEDIA_CONTROL, "get", "--now", "--no-artwork"],
            text=True,
            stderr=subprocess.DEVNULL
        )

        info = json.loads(output)
        position = float(info.get("elapsedTimeNow", info["elapsedTime"]))
        duration = info.get("duration")

        if direction > 0:
            position += step

            if duration is not None:
                position = min(
                    position,
                    max(0.0, float(duration) - 0.2)
                )
        else:
            position = max(0.0, position - step)

        current_direction, _ = active_direction()

        if current_direction == direction:
            subprocess.run(
                [MEDIA_CONTROL, "seek", str(position)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )

    except Exception:
        pass

    # Часто проверяем отпускание, чтобы перемотка не продолжала жить сама.
    deadline = time.monotonic() + interval

    while time.monotonic() < deadline:
        current_direction, _ = active_direction()

        if current_direction != direction:
            break

        time.sleep(0.005)
