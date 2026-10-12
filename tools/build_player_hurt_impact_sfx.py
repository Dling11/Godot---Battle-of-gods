"""Build the player's original short hurt-impact combat cue."""

from __future__ import annotations

import math
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 44_100


def _noise(index: int, seed: int) -> float:
	value = (index * 1_103_515_245 + seed) & 0x7FFFFFFF
	return value / 1_073_741_824.0 - 1.0


def _write_mono_wav(output_path: Path, samples: list[float], peak_limit: float) -> None:
	peak = max(max(abs(sample) for sample in samples), 0.001)
	gain = peak_limit / peak
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


def build_hurt_impact(output_path: Path) -> None:
	"""Make a brief cloth/body impact that is not an enemy vocal or claw cue."""
	duration_seconds = 0.19
	samples: list[float] = []
	filtered_noise = 0.0
	for index in range(round(SAMPLE_RATE * duration_seconds)):
		time_seconds = index / SAMPLE_RATE
		body = math.sin(math.tau * (138.0 - 36.0 * time_seconds) * time_seconds)
		body *= math.exp(-25.0 * time_seconds) * 0.46
		raw_noise = _noise(index, 37_219)
		filtered_noise = filtered_noise * 0.63 + raw_noise * 0.37
		cloth_envelope = math.exp(-32.0 * time_seconds)
		cloth = (raw_noise - filtered_noise) * cloth_envelope * 0.19
		breath = math.sin(math.tau * (248.0 - 84.0 * time_seconds) * time_seconds)
		breath *= math.exp(-18.0 * time_seconds) * 0.13
		samples.append(body + cloth + breath)
	_write_mono_wav(output_path, samples, 0.62)


if __name__ == "__main__":
	build_hurt_impact(Path("assets/audio/sfx/player_hurt_impact.wav"))
