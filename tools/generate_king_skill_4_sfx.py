"""Generate original non-tonal Skill 4 formation, impact, and explosion cues."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/audio/sfx/abilities/king"
RATE = 44_100


def _write(name: str, samples: list[float]) -> None:
    peak = max(max(abs(value) for value in samples), 0.001)
    gain = 0.92 / peak
    pcm = bytearray()
    for value in samples:
        shaped = math.tanh(value * gain * 1.15)
        pcm.extend(struct.pack("<h", round(max(-1.0, min(1.0, shaped)) * 32767)))
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / name), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(pcm)


def _noise(rng: random.Random, previous: float, smoothing: float) -> tuple[float, float]:
    current = previous * smoothing + rng.uniform(-1.0, 1.0) * (1.0 - smoothing)
    return current, current


def formation() -> list[float]:
    rng = random.Random(4041)
    duration = 0.48
    samples: list[float] = []
    low_noise = 0.0
    for index in range(round(RATE * duration)):
        t = index / RATE
        p = t / duration
        low_noise, noise = _noise(rng, low_noise, 0.86)
        rise = math.sin(min(p / 0.72, 1.0) * math.pi * 0.5) ** 2
        fall = max(0.0, 1.0 - max(p - 0.82, 0.0) / 0.18)
        sub = math.sin(2.0 * math.pi * (48.0 + 12.0 * p) * t) * 0.28 * rise
        air = noise * 0.52 * rise * fall
        samples.append((sub + air) * fall)
    return samples


def first_impact() -> list[float]:
    rng = random.Random(4042)
    duration = 0.28
    samples: list[float] = []
    low_noise = 0.0
    for index in range(round(RATE * duration)):
        t = index / RATE
        p = t / duration
        low_noise, noise = _noise(rng, low_noise, 0.73)
        transient = math.exp(-t * 34.0)
        sub = math.sin(2.0 * math.pi * (68.0 - 38.0 * p) * t) * math.exp(-t * 10.0) * 0.68
        stone = noise * transient * 0.82
        crack = rng.uniform(-1.0, 1.0) * math.exp(-((t - 0.035) / 0.012) ** 2) * 0.46
        samples.append(sub + stone + crack)
    return samples


def explosion() -> list[float]:
    rng = random.Random(4043)
    duration = 0.62
    samples: list[float] = []
    low_noise = 0.0
    for index in range(round(RATE * duration)):
        t = index / RATE
        p = t / duration
        low_noise, noise = _noise(rng, low_noise, 0.81)
        attack = min(t / 0.012, 1.0)
        decay = math.exp(-t * 5.1)
        sub = math.sin(2.0 * math.pi * (55.0 - 27.0 * p) * t) * attack * decay * 0.9
        body = noise * attack * decay * 0.9
        fracture = rng.uniform(-1.0, 1.0) * math.exp(-((t - 0.075) / 0.03) ** 2) * 0.55
        tail = math.sin(2.0 * math.pi * 34.0 * t) * math.exp(-t * 3.6) * 0.32
        samples.append(sub + body + fracture + tail)
    return samples


def main() -> None:
    _write("king_skill_4_formation.wav", formation())
    _write("king_skill_4_first_impact.wav", first_impact())
    _write("king_skill_4_explosion.wav", explosion())
    print("Generated King Skill 4 formation, first-impact, and explosion cues.")


if __name__ == "__main__":
    main()
