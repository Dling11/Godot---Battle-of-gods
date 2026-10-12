"""Build the Rootbound Husk's layered wood-creak and root-eruption cues."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 44_100
OUTPUT_DIR = (
    Path(__file__).resolve().parents[1]
    / "assets/audio/sfx/enemies/rootbound_husk"
)


def envelope(time: float, start: float, duration: float, power: float = 2.0) -> float:
    local_time = (time - start) / duration
    if local_time < 0.0 or local_time >= 1.0:
        return 0.0
    return (1.0 - local_time) ** power


def write_wave(path: Path, values: list[float]) -> None:
    peak = max(max(abs(value) for value in values), 0.001)
    gain = 0.92 / peak
    samples = [
        round(max(-1.0, min(1.0, value * gain)) * 32767.0)
        for value in values
    ]
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(SAMPLE_RATE)
        output.writeframes(struct.pack("<%dh" % len(samples), *samples))


def build_creak() -> list[float]:
    duration = 0.72
    random_source = random.Random(5301)
    values: list[float] = []
    held_noise = 0.0
    for index in range(round(SAMPLE_RATE * duration)):
        time = index / SAMPLE_RATE
        if index % 31 == 0:
            held_noise = random_source.random() * 2.0 - 1.0
        rise = min(time / 0.48, 1.0)
        fall = envelope(time, 0.48, 0.24, 1.4)
        body = math.sin(math.tau * (78.0 + 24.0 * rise) * time) * 0.18
        flex = math.sin(math.tau * (174.0 - 58.0 * rise) * time + 0.7) * 0.11
        fibers = held_noise * (0.05 + 0.13 * rise)
        snap = math.sin(math.tau * 410.0 * (time - 0.54)) * envelope(time, 0.54, 0.11) * 0.22
        values.append((body + flex + fibers) * rise * fall + snap)
    return values


def build_eruption() -> list[float]:
    duration = 0.52
    random_source = random.Random(5302)
    values: list[float] = []
    for index in range(round(SAMPLE_RATE * duration)):
        time = index / SAMPLE_RATE
        earth = (
            math.sin(math.tau * (52.0 - 18.0 * time) * time)
            * envelope(time, 0.0, 0.46, 1.5)
            * 0.42
        )
        wood = 0.0
        for start, frequency, strength in [
            (0.018, 690.0, 0.25),
            (0.068, 470.0, 0.20),
            (0.132, 820.0, 0.16),
            (0.205, 360.0, 0.13),
        ]:
            wood += (
                math.sin(math.tau * frequency * (time - start))
                * envelope(time, start, 0.075)
                * strength
            )
        debris = (
            random_source.random() * 2.0 - 1.0
        ) * envelope(time, 0.025, 0.34, 1.8) * 0.22
        values.append(earth + wood + debris)
    return values


def main() -> None:
    write_wave(OUTPUT_DIR / "rootbound_husk_root_creak.wav", build_creak())
    write_wave(OUTPUT_DIR / "rootbound_husk_root_eruption.wav", build_eruption())


if __name__ == "__main__":
    main()
