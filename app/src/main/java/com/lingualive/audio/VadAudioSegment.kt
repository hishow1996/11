package com.lingualive.audio
data class VadAudioSegment(val samples:FloatArray,val startSample:Long,val endSample:Long){
 val durationMs:Long get()=(endSample-startSample)*1000L/16000L
}