"""Generate King's original Riftbreak ground-slam cue.

The output is deterministic and assembled from procedural oscillators/noise,
so the project owns the result without external attribution requirements.
"""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets/audio/sfx/abilities/king/riftbreak_ground_slam.wav"
SAMPLE_RATE = 44_100
DURATION_SECONDS = 0.52
RANDOM_SEED = 0xB17B4EA


def _envelope(time_seconds: float, attack: float, decay: float) -> float:
    if time_seconds < 0.0:
        return 0.0
    return min(time_seconds / max(attack, 0.0001), 1.0) * math.exp(
        -time_seconds / max(decay, 0.0001)
    )


def main() -> None:
    rng = random.Random(RANDOM_SEED)
    sample_count = round(SAMPLE_RATE * DURATION_SECONDS)
    coarse = 0.0
    samples: list[float] = []

    for index in range(sample_count):
        time_seconds = index / SAMPLE_RATE
        coarse = coarse * 0.78 + rng.uniform(-1.0, 1.0) * 0.22
        grit = rng.uniform(-1.0, 1.0)

        ground_thump = (
            math.sin(math.tau * (78.0 - 38.0 * time_seconds) * time_seconds)
            * _envelope(time_seconds, 0.0015, 0.14)
            * 0.78
        )
        stone_crack = (
            (coarse * 0.72 + grit * 0.28)
            * _envelope(time_seconds, 0.001, 0.075)
            * 0.82
        )
        rubble_tail = (
            coarse
            * _envelope(time_seconds - 0.045, 0.006, 0.21)
            * 0.42
        )
        secondary_break = (
            (grit - coarse)
            * _envelope(time_seconds - 0.095, 0.002, 0.085)
            * 0.30
        )
        samples.append(ground_thump + stone_crack + rubble_tail + secondary_break)

    peak = max(abs(sample) for sample in samples)
    gain = 0.90 / max(peak, 0.0001)
    pcm = b"".join(
        struct.pack("<h", round(max(-1.0, min(1.0, sample * gain)) * 32767.0))
        for sample in samples
    )

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUTPUT), "wb") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        wav_file.writeframes(pcm)
    print(f"Wrote {OUTPUT.relative_to(ROOT)} ({DURATION_SECONDS:.2f}s mono 44.1kHz)")


if __name__ == "__main__":
    main()
