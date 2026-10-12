"""Build the original deterministic player level-up chime."""

from __future__ import annotations

import math
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 44_100
DURATION_SECONDS = 0.82
OUTPUT = (
    Path(__file__).resolve().parents[1]
    / "assets"
    / "audio"
    / "sfx"
    / "ui"
    / "player_level_up_chime.wav"
)


def envelope(time_seconds: float) -> float:
    attack = min(time_seconds / 0.018, 1.0)
    release = max(1.0 - time_seconds / DURATION_SECONDS, 0.0) ** 1.8
    return attack * release


def sample(time_seconds: float) -> float:
    notes = ((523.25, 0.00), (659.25, 0.09), (783.99, 0.18), (1046.50, 0.32))
    value = 0.0
    for frequency, delay in notes:
        note_time = time_seconds - delay
        if note_time < 0.0:
            continue
        note_decay = math.exp(-4.8 * note_time)
        value += math.sin(math.tau * frequency * note_time) * note_decay
        value += 0.23 * math.sin(math.tau * frequency * 2.0 * note_time) * note_decay
    shimmer = 0.09 * math.sin(math.tau * 1567.98 * time_seconds)
    return (value * 0.22 + shimmer) * envelope(time_seconds)


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    frame_count = int(SAMPLE_RATE * DURATION_SECONDS)
    frames = bytearray()
    for frame_index in range(frame_count):
        value = max(-1.0, min(1.0, sample(frame_index / SAMPLE_RATE)))
        frames.extend(struct.pack("<h", int(value * 32767)))
    with wave.open(str(OUTPUT), "wb") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        wav_file.writeframes(frames)


if __name__ == "__main__":
    main()
