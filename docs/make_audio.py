import math, random, wave, struct, os
RATE=44100
random.seed(7)
def write_wav(path, seconds, fn):
    n=int(RATE*seconds)
    with wave.open(path,'w') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE)
        frames=[]
        for i in range(n):
            t=i/RATE
            v=max(-1,min(1,fn(t)))
            frames.append(struct.pack('<h',int(v*30000)))
        w.writeframes(b''.join(frames))

def engine(t):
    # Layered low-frequency diesel pulses + filtered-ish mechanical harmonics.
    rpm=8.2
    pulse=(math.sin(2*math.pi*rpm*t)+0.55*math.sin(2*math.pi*rpm*2*t)+0.25*math.sin(2*math.pi*rpm*4*t))
    harmonics=0.20*math.sin(2*math.pi*92*t)+0.10*math.sin(2*math.pi*184*t)
    rumble=0.08*math.sin(2*math.pi*38*t)
    return (pulse*0.22+harmonics+rumble)*0.82

def brake(t):
    attack=min(1,t*18); decay=max(0,1-t/0.95)
    noise=random.uniform(-1,1)*0.22
    hiss=0.25*math.sin(2*math.pi*1800*t)+0.12*math.sin(2*math.pi*2400*t)
    return (noise+hiss)*attack*decay
os.makedirs('audio',exist_ok=True)
write_wav('audio/engine_loop.wav',4.0,engine)
write_wav('audio/air_brake.wav',0.95,brake)
print('generated realistic-style engine_loop.wav and air_brake.wav')
