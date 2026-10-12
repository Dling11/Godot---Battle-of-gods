"""Generate non-tonal launch and rocky landing cues for Sovereign Pursuit."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LANDING_OUTPUT = ROOT / "assets/audio/sfx/abilities/king/sovereign_pursuit_landing.wav"
LAUNCH_OUTPUT = ROOT / "assets/audio/sfx/abilities/king/sovereign_pursuit_launch.wav"
RATE = 44100
DURATION = 0.56


def _write(path: Path, samples: list[float]) -> None:
    peak = max(max(abs(sample) for sample in samples), 0.0001)
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as target:
        target.setnchannels(1)
        target.setsampwidth(2)
        target.setframerate(RATE)
        target.writeframes(b"".join(struct.pack("<h", round(max(-1.0, min(1.0, sample * 0.90 / peak)) * 32767.0)) for sample in samples))


def main() -> None:
    rng = random.Random(7413)
    landing: list[float] = []
    low_noise = 0.0
    coarse_noise = 0.0
    for index in range(round(RATE * DURATION)):
        time = index / RATE
        raw = rng.uniform(-1.0, 1.0)
        low_noise = low_noise * 0.97 + raw * 0.03
        coarse_noise = coarse_noise * 0.72 + raw * 0.28
        thump = math.sin(math.tau * (70.0 - 24.0 * time) * time) * math.exp(-time * 15.0) * 0.62
        earth = coarse_noise * math.exp(-time * 10.0) * 0.72
        rubble = 0.0
        for onset, strength in [(0.055, 0.34), (0.11, 0.25), (0.19, 0.18), (0.29, 0.12)]:
            local = time - onset
            if local >= 0.0:
                rubble += (coarse_noise - low_noise) * math.exp(-local * 22.0) * strength
        landing.append(thump + earth + rubble)

    launch: list[float] = []
    smooth = 0.0
    previous = 0.0
    for index in range(round(RATE * 0.24)):
        time = index / RATE
        raw = rng.uniform(-1.0, 1.0)
        smooth = smooth * 0.92 + raw * 0.08
        airy = smooth - previous
        previous = smooth
        envelope = min(time / 0.025, 1.0) * math.exp(-time * 13.0)
        cloth = rng.uniform(-1.0, 1.0) * math.exp(-time * 25.0) * 0.12
        launch.append(airy * envelope * 4.4 + cloth)

    _write(LANDING_OUTPUT, landing)
    _write(LAUNCH_OUTPUT, launch)
    print(f"Wrote {LANDING_OUTPUT.relative_to(ROOT)} and {LAUNCH_OUTPUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
