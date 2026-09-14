package com.lingualive.audio
class SileroVadProbabilityTracker{var last:Float=0f;private set;fun update(p:Float):Float{last=p.coerceIn(0f,1f);return last}fun reset(){last=0f}}