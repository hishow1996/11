import math, random, struct, wave, os
RATE = 44100
random.seed(33)

def write(path, seconds, fn):
    os.makedirs('audio', exist_ok=True)
    with wave.open(path, 'w') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE)
        data = bytearray()
        for i in range(int(seconds * RATE)):
            t = i / RATE
            v = max(-1.0, min(1.0, fn(t)))
            data += struct.pack('<h', int(v * 28000))
        w.writeframes(data)

def noise_loop(t, seed, low=0.08, high=0.22):
    # Deterministic pseudo-noise with several incommensurate bands.
    n = sum(math.sin(2 * math.pi * (seed + k * 37.17) * t + k) for k in range(1, 8)) / 7.0
    return n * (low + high * (0.5 + 0.5 * math.sin(2 * math.pi * 0.17 * t)))

def rain(t):
    drops = noise_loop(t, 173, 0.18, 0.55)
    hiss = 0.18 * math.sin(2 * math.pi * 2600 * t) + 0.09 * math.sin(2 * math.pi * 4100 * t)
    modulation = 0.72 + 0.28 * math.sin(2 * math.pi * 0.11 * t)
    return (drops + hiss) * modulation * 0.55

def wind(t):
    gust = 0.52 + 0.48 * math.sin(2 * math.pi * 0.07 * t + 1.2)
    low = 0.32 * math.sin(2 * math.pi * 84 * t) + 0.15 * math.sin(2 * math.pi * 137 * t)
    return (low + noise_loop(t, 49, 0.12, 0.25)) * gust * 0.55

def wet_tire(t):
    # Broad-band road hiss plus rhythmic wheel spray pulses.
    spray = noise_loop(t, 311, 0.22, 0.48)
    pulse = max(0.0, math.sin(2 * math.pi * 6.2 * t)) ** 8
    splashes = pulse * (0.32 + 0.18 * math.sin(2 * math.pi * 92 * t))
    return (spray * 0.5 + splashes) * 0.72

def snow_tire(t):
    # Soft granular crunch: irregular low pulses and granular high frequencies.
    crunch = max(0.0, math.sin(2 * math.pi * 3.6 * t + 0.5)) ** 10
    grain = noise_loop(t, 701, 0.08, 0.25)
    body = 0.24 * math.sin(2 * math.pi * 118 * t) + 0.12 * math.sin(2 * math.pi * 226 * t)
    return (crunch * (0.35 + grain) + body * 0.35) * 0.72

def thunder(t):
    attack = min(1.0, t * 10.0)
    decay = max(0.0, 1.0 - t / 3.2)
    low = 0.6 * math.sin(2 * math.pi * 42 * t) + 0.3 * math.sin(2 * math.pi * 63 * t)
    rumble = noise_loop(t, 17, 0.25, 0.42)
    return (low + rumble) * attack * decay * 0.62

write('audio/rain_ambient.wav', 8.0, rain)
write('audio/wind_ambient.wav', 8.0, wind)
write('audio/tire_wet.wav', 4.0, wet_tire)
write('audio/tire_snow.wav', 4.0, snow_tire)
write('audio/thunder_rumble.wav', 3.2, thunder)
print('generated rain, wind, wet-tire, snow-tire and thunder WAV assets')
