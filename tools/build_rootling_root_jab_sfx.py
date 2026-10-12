"""Build Rootling's original short wood-crack/root-pop combat cue."""

from __future__ import annotations

import math
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 44_100
DURATION_SECONDS = 0.31


def _noise(index: int) -> float:
    # Deterministic pseudo-noise keeps the authored WAV reproducible.
    value = (index * 1_103_515_245 + 12_345) & 0x7FFFFFFF
    return value / 1_073_741_824.0 - 1.0


def _crack_envelope(time_seconds: float, start: float, duration: float) -> float:
    local_time = time_seconds - start
    if local_time < 0.0 or local_time > duration:
        return 0.0
    return (1.0 - local_time / duration) ** 3


def build(output_path: Path) -> None:
    sample_count = round(SAMPLE_RATE * DURATION_SECONDS)
    samples: list[float] = []
    low_noise = 0.0
    for index in range(sample_count):
        time_seconds = index / SAMPLE_RATE
        # A soft low wooden push makes the impact feel rooted in the ground.
        falling_frequency = 118.0 - 58.0 * min(time_seconds / 0.19, 1.0)
        thump = math.sin(math.tau * falling_frequency * time_seconds) * math.exp(-15.5 * time_seconds) * 0.44
        # Three filtered, short grain cracks read as roots splitting soil.
        raw_noise = _noise(index)
        low_noise = low_noise * 0.78 + raw_noise * 0.22
        crack = low_noise * (
            _crack_envelope(time_seconds, 0.018, 0.07) * 0.34
            + _crack_envelope(time_seconds, 0.078, 0.055) * 0.23
            + _crack_envelope(time_seconds, 0.145, 0.04) * 0.13
        )
        # A tiny high snap provides enough attack definition at gameplay volume.
        snap = math.sin(math.tau * 610.0 * time_seconds) * _crack_envelope(time_seconds, 0.018, 0.025) * 0.16
        samples.append(thump + crack + snap)

    peak = max(max(abs(sample) for sample in samples), 0.001)
    gain = 0.84 / peak
    payload = b"".join(
        struct.pack("<h", max(-32767, min(32767, round(sample * gain * 32767))))
        for sample in samples
    )
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(output_path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(SAMPLE_RATE)
        output.writeframes(payload)


if __name__ == "__main__":
    build(Path("assets/audio/sfx/rootling_root_jab.wav"))
