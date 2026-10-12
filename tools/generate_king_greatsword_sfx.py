"""Original deterministic steel/air/leather cues; no external recordings."""
from pathlib import Path
import math
import random
import struct
import wave

OUT = Path(__file__).resolve().parents[1] / 'assets/audio/sfx/player/greatsword'
OUT.mkdir(parents=True, exist_ok=True)
RATE = 44100
for name, length, weight in [('cut', .24, 1), ('return', .22, .85), ('cleave', .38, 1.6), ('resolve', .5, 1), ('step', .08, 1)]:
    rng = random.Random(name)
    samples = []
    low = 0.0
    for i in range(int(length * RATE)):
        t = i / RATE
        p = t / length
        noise = rng.uniform(-1, 1)
        low = low * .86 + noise * .14
        attack = min(1, t / .009)
        if name == 'resolve':
            v = sum(math.sin(math.tau * f * t) * math.exp(-t * decay) for f, decay in [(660, 8), (990, 10), (1320, 12)]) * .18 * attack
        elif name == 'step':
            v = (low * .8 + math.sin(math.tau * 105 * t) * .15) * math.exp(-t * 65) * attack
        else:
            envelope = math.sin(math.pi * min(1, p)) ** 1.5
            air = (noise - low) * .21 + low * .65 * weight
            steel = math.sin(math.tau * (1400*t - 850*t*t/length)) * .075
            body = math.sin(math.tau * (85*t - 22*t*t/length)) * .18 * weight
            v = (air + steel + body) * envelope * attack
        samples.append(v)
    peak = max(abs(v) for v in samples)
    gain = min(1, .82 / max(peak, .001))
    with wave.open(str(OUT / (name + '.wav')), 'wb') as f:
        f.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
        f.writeframes(b''.join(struct.pack('<h', int(max(-1, min(1, v * gain)) * 32767)) for v in samples))
print('KING_GREATSW0RD_SFX: 5 original peak-limited cues')
