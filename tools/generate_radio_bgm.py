import math
import wave
from pathlib import Path

sample_rate = 44100
duration = 48.0
frames = int(sample_rate * duration)
out = Path('/home/ubuntu/repo11/audio/bgm_burn_loop.wav')
out.parent.mkdir(parents=True, exist_ok=True)

# 132 BPM, D minor: punchier synth arpeggio for the anime night-drive station.
bpm = 132.0
beat = 60.0 / bpm
chords = [(146.83, 174.61, 220.0), (130.81, 155.56, 196.0), (116.54, 146.83, 174.61), (130.81, 164.81, 220.0)]
lead_notes = [293.66, 349.23, 392.0, 440.0, 392.0, 349.23, 293.66, 261.63]

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
        bass = math.sin(2 * math.pi * chord[0] * 0.5 * t) * (0.5 + 0.5 * math.sin(2 * math.pi * 0.5 * t))
        step = int(t / (beat * 0.25)) % len(lead_notes)
        gate = max(0.0, 1.0 - (phase % (beat * 0.25)) / (beat * 0.25))
        lead = math.sin(2 * math.pi * lead_notes[step] * t) * gate
        kick_phase = t % beat
        kick = math.exp(-kick_phase * 24.0) * math.sin(2 * math.pi * (72.0 - kick_phase * 28.0) * t)
        snare_phase = (t + beat * 0.5) % beat
        snare = math.exp(-snare_phase * 30.0) * math.sin(2 * math.pi * 1800.0 * t) * 0.45
        hat = math.sin(2 * math.pi * 4100.0 * t) * (1.0 if int(t / (beat * 0.25)) % 2 == 0 else 0.0) * 0.045
        signal = 0.10 * pad + 0.14 * bass + 0.085 * lead + 0.13 * kick + 0.08 * snare + hat
        fade = min(1.0, t / 1.0, (duration - t) / 1.0)
        signal *= fade
        left = max(-1.0, min(1.0, signal * 0.96))
        right = max(-1.0, min(1.0, signal * 1.04))
        data.extend(int(left * 32767).to_bytes(2, 'little', signed=True))
        data.extend(int(right * 32767).to_bytes(2, 'little', signed=True))
    wf.writeframes(data)
print(out)
