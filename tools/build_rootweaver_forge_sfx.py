"""Build a short, original Living Rootforge wood/stone strike."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 44_100
DURATION_SECONDS = 0.34
OUTPUT = Path(__file__).resolve().parents[1] / (
    "assets/audio/sfx/npcs/rootweaver/rootweaver_rootforge_strike.wav"
)


def _sample(index: int, rng: random.Random) -> float:
    time = index / SAMPLE_RATE
    wooden_knock = math.sin(math.tau * 118.0 * time) * math.exp(-time * 19.0)
    stone_body = math.sin(math.tau * 236.0 * time + 0.35) * math.exp(-time * 26.0)
    root_creak = math.sin(math.tau * (64.0 - 18.0 * time) * time) * math.exp(-time * 11.0)
    transient = (rng.random() * 2.0 - 1.0) * math.exp(-time * 48.0)
    return max(-1.0, min(1.0, 0.46 * wooden_knock + 0.23 * stone_body + 0.18 * root_creak + 0.13 * transient))


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    rng = random.Random(0xB067)
    frame_count = round(SAMPLE_RATE * DURATION_SECONDS)
    samples = [_sample(index, rng) for index in range(frame_count)]
    peak = max(abs(value) for value in samples) or 1.0
    scale = 0.82 / peak
    payload = b"".join(
        struct.pack("<h", round(value * scale * 32767.0))
        for value in samples
    )
    with wave.open(str(OUTPUT), "wb") as stream:
        stream.setnchannels(1)
        stream.setsampwidth(2)
        stream.setframerate(SAMPLE_RATE)
        stream.writeframes(payload)
    print(f"Wrote {OUTPUT}")


if __name__ == "__main__":
    main()
