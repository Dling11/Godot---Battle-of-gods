from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets/audio/sfx/enemies/crag_bear"
RATE = 44100


def _write_wav(path: Path, samples: list[float]) -> None:
    peak = max(max(abs(sample) for sample in samples), 0.001)
    scale = 0.9 / peak
    pcm = b"".join(
        struct.pack(
            "<h", int(max(-1.0, min(1.0, sample * scale)) * 32767)
        )
        for sample in samples
    )
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as stream:
        stream.setnchannels(1)
        stream.setsampwidth(2)
        stream.setframerate(RATE)
        stream.writeframes(pcm)


def _burst(t: float, start: float, duration: float, rng: random.Random) -> float:
    if t < start or t >= start + duration:
        return 0.0
    phase = (t - start) / duration
    return rng.uniform(-1.0, 1.0) * math.sin(math.pi * phase) * (1.0 - phase)


def _claw_swipe() -> list[float]:
    """Heavy air displacement, body commitment, then three short claw tears."""
    rng = random.Random(60241)
    duration = 0.38
    result: list[float] = []
    low_noise = 0.0
    high_noise = 0.0
    for index in range(int(duration * RATE)):
        t = index / RATE
        raw = rng.uniform(-1.0, 1.0)
        low_noise = low_noise * 0.965 + raw * 0.035
        high_noise = high_noise * 0.55 + raw * 0.45

        sweep_phase = min(t / 0.22, 1.0)
        sweep_envelope = math.sin(math.pi * sweep_phase) ** 1.8 if t < 0.22 else 0.0
        whoosh = (high_noise - low_noise) * sweep_envelope * 0.72

        body = (
            math.sin(2.0 * math.pi * (92.0 - 44.0 * t) * t)
            * math.exp(-22.0 * max(t - 0.135, 0.0))
            if t >= 0.135
            else 0.0
        )
        tears = sum(
            _burst(t, start, 0.052, rng) * amount
            for start, amount in ((0.145, 0.62), (0.169, 0.48), (0.194, 0.34))
        )
        tail = low_noise * math.exp(-9.0 * max(t - 0.16, 0.0)) * 0.25
        result.append(whoosh + body * 0.78 + tears + tail)
    return result


def _ground_slam() -> list[float]:
    """Layered earth impact: low body, rock break, debris, and a short sub tail."""
    rng = random.Random(60813)
    duration = 0.62
    result: list[float] = []
    earth = 0.0
    grit = 0.0
    for index in range(int(duration * RATE)):
        t = index / RATE
        raw = rng.uniform(-1.0, 1.0)
        earth = earth * 0.94 + raw * 0.06
        grit = grit * 0.62 + raw * 0.38

        pitch = 78.0 - 43.0 * min(t / duration, 1.0)
        body = math.sin(2.0 * math.pi * pitch * t) * math.exp(-10.5 * t)
        sub = math.sin(2.0 * math.pi * 38.0 * t) * math.exp(-7.2 * t)
        initial_crack = _burst(t, 0.0, 0.052, rng) * 1.0
        fractures = sum(
            _burst(t, start, 0.038, rng) * amount
            for start, amount in (
                (0.044, 0.62),
                (0.089, 0.46),
                (0.146, 0.33),
                (0.221, 0.2),
            )
        )
        settling = earth * math.exp(-5.2 * t) * 0.66
        debris = grit * math.exp(-7.5 * max(t - 0.08, 0.0)) * 0.22
        result.append(
            body * 1.12
            + sub * 0.72
            + initial_crack
            + fractures
            + settling
            + debris
        )
    return result


def main() -> None:
    _write_wav(OUTPUT / "crag_bear_claw_swipe.wav", _claw_swipe())
    _write_wav(OUTPUT / "crag_bear_ground_slam.wav", _ground_slam())
    print("Generated Crag Bear claw swipe and ground slam SFX.")


if __name__ == "__main__":
    main()
