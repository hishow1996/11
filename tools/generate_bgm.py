import math
import wave
from pathlib import Path

sample_rate = 44100
duration = 48.0
frames = int(sample_rate * duration)
out = Path('/home/ubuntu/repo11/audio/bgm_route_loop.wav')
out.parent.mkdir(parents=True, exist_ok=True)

# 96 BPM, four-bar loop in A minor: bright anime road-trip synth palette.
bpm = 96.0
beat = 60.0 / bpm
chords = [(220.0, 261.63, 329.63), (196.0, 246.94, 293.66), (174.61, 220.0, 261.63), (196.0, 246.94, 329.63)]
notes = [440.0, 523.25, 587.33, 659.25, 587.33, 523.25, 440.0, 392.0]
with wave.open(str(out), 'w') as wf:
    wf.setnchannels(2)
    wf.setsampwidth(2)
    wf.setframerate(sample_rate)
    data = bytearray()
    for i in range(frames):
        t = i / sample_rate
        bar = int(t / (beat * 4.0)) % len(chords)
        chord = chords[bar]
        phase = t % (beat * 4.0)
        pad = sum(math.sin(2 * math.pi * f * t) for f in chord) / 3.0
        bass = math.sin(2 * math.pi * chord[0] * 0.5 * t) * (0.5 + 0.5 * math.sin(2 * math.pi * 0.25 * t))
        step = int(t / (beat * 0.5)) % len(notes)
        lead = math.sin(2 * math.pi * notes[step] * t) * max(0.0, 1.0 - (phase % (beat * 0.5)) / (beat * 0.5))
        kick = math.exp(-((t % beat) * 18.0)) * math.sin(2 * math.pi * 75.0 * t)
        hat = math.sin(2 * math.pi * 3200.0 * t) * (1.0 if (int(t / (beat * 0.5)) % 2) else 0.0) * 0.035
        signal = 0.13 * pad + 0.12 * bass + 0.07 * lead + 0.08 * kick + hat
        fade = min(1.0, t / 1.0, (duration - t) / 1.0)
        signal *= fade
        left = max(-1.0, min(1.0, signal * 0.94))
        right = max(-1.0, min(1.0, signal * 1.06))
        data.extend(int(left * 32767).to_bytes(2, 'little', signed=True))
        data.extend(int(right * 32767).to_bytes(2, 'little', signed=True))
    wf.writeframes(data)
print(out)
