package com.lingualive.audio
class VadSegmentAccumulator {
 private val data=ArrayList<Float>()
 private var startSample=0L
 fun begin(start:Long){data.clear();startSample=start}
 fun append(samples:FloatArray){for(v in samples)data.add(v)}
 fun finish(end:Long):VadAudioSegment?{if(data.isEmpty())return null;return VadAudioSegment(data.toFloatArray(),startSample,end)}
 fun clear(){data.clear()}
}