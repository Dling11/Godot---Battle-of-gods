from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets/audio/sfx/enemies/armored_hog"
RATE = 44100


def write_wav(path: Path, samples: list[float]) -> None:
    peak = max(max(abs(sample) for sample in samples), 0.001)
    scale = 0.88 / peak
    pcm = b"".join(struct.pack("<h", int(max(-1.0, min(1.0, sample * scale)) * 32767)) for sample in samples)
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as stream:
        stream.setnchannels(1)
        stream.setsampwidth(2)
        stream.setframerate(RATE)
        stream.writeframes(pcm)


def noise_burst(time: float, start: float, duration: float, rng: random.Random) -> float:
    if time < start or time >= start + duration:
        return 0.0
    phase = (time - start) / duration
    envelope = math.sin(math.pi * phase) * (1.0 - phase)
    return rng.uniform(-1.0, 1.0) * envelope


def hoof() -> list[float]:
    rng = random.Random(412)
    duration = 0.16
    result: list[float] = []
    filtered = 0.0
    for index in range(int(duration * RATE)):
        t = index / RATE
        thump = math.sin(2.0 * math.pi * (94.0 - 35.0 * t) * t) * math.exp(-32.0 * t)
        raw = noise_burst(t, 0.0, 0.07, rng)
        filtered = filtered * 0.82 + raw * 0.18
        bark_click = noise_burst(t, 0.018, 0.035, rng) * 0.34
        result.append(thump * 0.92 + filtered * 0.55 + bark_click)
    return result


def brace() -> list[float]:
    rng = random.Random(781)
    duration = 0.52
    result: list[float] = []
    filtered = 0.0
    for index in range(int(duration * RATE)):
        t = index / RATE
        growl = (
            math.sin(2.0 * math.pi * 58.0 * t)
            + 0.55 * math.sin(2.0 * math.pi * 83.0 * t)
        ) * math.sin(min(t / 0.08, 1.0) * math.pi * 0.5) * math.exp(-3.1 * t)
        raw = rng.uniform(-1.0, 1.0)
        filtered = filtered * 0.94 + raw * 0.06
        scrape = noise_burst(t, 0.22, 0.24, rng)
        result.append(growl * 0.38 + filtered * 0.18 + scrape * 0.42)
    return result


def crash() -> list[float]:
    rng = random.Random(991)
    duration = 0.46
    result: list[float] = []
    filtered = 0.0
    for index in range(int(duration * RATE)):
        t = index / RATE
        impact = math.sin(2.0 * math.pi * (72.0 - 28.0 * t) * t) * math.exp(-14.0 * t)
        raw = rng.uniform(-1.0, 1.0)
        filtered = filtered * 0.86 + raw * 0.14
        crack = sum(noise_burst(t, offset, 0.035, rng) for offset in (0.0, 0.055, 0.11))
        result.append(impact * 1.1 + filtered * math.exp(-6.0 * t) * 0.72 + crack * 0.36)
    return result


def main() -> None:
    write_wav(OUTPUT / "armored_hog_hoof.wav", hoof())
    write_wav(OUTPUT / "armored_hog_brace.wav", brace())
    write_wav(OUTPUT / "armored_hog_crash.wav", crash())
    print("Generated Armored Hog hoof, brace, and crash SFX.")


if __name__ == "__main__":
    main()
