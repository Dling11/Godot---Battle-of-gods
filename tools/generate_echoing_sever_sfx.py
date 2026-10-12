"""Generate Battle of Gods' original Echoing Sever fracture cue.

The output is deterministic, mono, immediately responsive, and assembled from
procedural oscillators/noise. It has no external copyright or attribution.
"""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets/audio/sfx/abilities/king/echoing_sever_echo_fracture.wav"
SAMPLE_RATE = 44_100
DURATION_SECONDS = 0.42
RANDOM_SEED = 0xEC401


def _smooth_noise(rng: random.Random, sample_count: int, smoothing: float) -> list[float]:
    value = 0.0
    output: list[float] = []
    for _ in range(sample_count):
        value = value * smoothing + rng.uniform(-1.0, 1.0) * (1.0 - smoothing)
        output.append(value)
    return output


def _envelope(time_seconds: float, attack: float, decay: float) -> float:
    if time_seconds < 0.0:
        return 0.0
    attack_gain = min(time_seconds / max(attack, 0.0001), 1.0)
    return attack_gain * math.exp(-time_seconds / max(decay, 0.0001))


def main() -> None:
    rng = random.Random(RANDOM_SEED)
    sample_count = round(SAMPLE_RATE * DURATION_SECONDS)
    coarse_noise = _smooth_noise(rng, sample_count, 0.72)
    fine_noise = _smooth_noise(rng, sample_count, 0.18)
    samples: list[float] = []

    shard_times = (0.038, 0.074, 0.116, 0.164)
    shard_frequencies = (1420.0, 1780.0, 1160.0, 2060.0)
    for index in range(sample_count):
        time_seconds = index / SAMPLE_RATE

        sub_thump = (
            math.sin(math.tau * (92.0 - 28.0 * time_seconds) * time_seconds)
            * _envelope(time_seconds, 0.004, 0.105)
            * 0.42
        )
        root_crack = (
            (coarse_noise[index] * 0.82 + fine_noise[index] * 0.18)
            * _envelope(time_seconds, 0.0015, 0.075)
            * 0.72
        )
        crystalline_fall = (
            math.sin(math.tau * (910.0 - 530.0 * time_seconds) * time_seconds)
            * _envelope(time_seconds, 0.002, 0.17)
            * 0.23
        )

        shards = 0.0
        for shard_time, frequency in zip(shard_times, shard_frequencies):
            local_time = time_seconds - shard_time
            shards += (
                math.sin(math.tau * frequency * local_time)
                * _envelope(local_time, 0.001, 0.032)
                * 0.18
            )

        tail = (
            fine_noise[index]
            * _envelope(time_seconds - 0.09, 0.008, 0.12)
            * 0.16
        )
        samples.append(sub_thump + root_crack + crystalline_fall + shards + tail)

    peak = max(abs(sample) for sample in samples)
    gain = 0.88 / max(peak, 0.0001)
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
