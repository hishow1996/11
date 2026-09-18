from pathlib import Path
import math, random, wave, struct

ROOT = Path(__file__).resolve().parents[1] / 'audio'
ROOT.mkdir(exist_ok=True)
RATE = 44100
random.seed(7)

def write(name, seconds, fn):
    n = int(seconds * RATE)
    path = ROOT / name
    with wave.open(str(path), 'w') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE)
        frames = bytearray()
        for i in range(n):
            t = i / RATE
            value = max(-1.0, min(1.0, fn(t, seconds)))
            frames += struct.pack('<h', int(value * 28000))
        w.writeframes(frames)
    print(path.name)

def env(t, d, attack=0.01, release=0.08):
    return min(1.0, t / attack) * min(1.0, (d - t) / release)

def tone(freq, d, amp=0.35, decay=3.0):
    return lambda t, _: amp * math.exp(-decay*t) * math.sin(2*math.pi*freq*t)

def chirp(f0, f1, d, amp=0.35):
    return lambda t, dur: amp * env(t, dur) * math.sin(2*math.pi*(f0*t + (f1-f0)*t*t/(2*dur)))

def noise(d, amp=0.3, tone_freq=0):
    phase = random.random() * 10
    return lambda t, _: amp * env(t, d, 0.002, 0.14) * (random.uniform(-1,1) * 0.7 + (math.sin(2*math.pi*tone_freq*t+phase) if tone_freq else 0.0) * 0.3)

write('reverse_beeper.wav', 0.72, lambda t,d: (0.35 if int(t*4)%2==0 else 0) * math.sin(2*math.pi*920*t) * env(t,d,0.01,0.04))
write('turn_signal.wav', 0.18, tone(880, 0.18, 0.3, 5.0))
write('gear_shift.wav', 0.28, lambda t,d: env(t,d) * (0.22*math.sin(2*math.pi*180*t) + 0.12*math.sin(2*math.pi*520*t)))
write('tire_skid.wav', 0.7, noise(0.7, 0.42, 1800))
write('collision_metal.wav', 0.65, lambda t,d: noise(d,0.5,90)(t,d) + 0.24*math.sin(2*math.pi*72*t)*math.exp(-5*t))
write('guardrail_scrape.wav', 0.8, noise(0.8, 0.34, 2400))
write('water_splash.wav', 0.5, noise(0.5, 0.3, 520))
write('wiper_swipe.wav', 0.32, chirp(180, 620, 0.32, 0.18))
write('refuel_start.wav', 0.45, chirp(420, 760, 0.45, 0.22))
write('repair_start.wav', 0.55, lambda t,d: env(t,d) * (0.16*math.sin(2*math.pi*230*t) + 0.08*math.sin(2*math.pi*510*t)))
write('delivery_complete.wav', 1.25, lambda t,d: env(t,d,0.01,0.3) * (0.22*math.sin(2*math.pi*523*t) + 0.18*math.sin(2*math.pi*659*t) + 0.14*math.sin(2*math.pi*784*t)))
write('upgrade_purchase.wav', 0.7, lambda t,d: env(t,d,0.01,0.12) * (0.2*math.sin(2*math.pi*660*t) + 0.14*math.sin(2*math.pi*990*t)))
write('ui_click.wav', 0.09, tone(740, 0.09, 0.26, 8.0))
write('warning_alert.wav', 0.5, lambda t,d: (0.24 if int(t*5)%2==0 else 0) * math.sin(2*math.pi*660*t) * env(t,d,0.005,0.04))
