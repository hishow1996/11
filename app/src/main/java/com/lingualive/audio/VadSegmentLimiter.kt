package com.lingualive.audio
class VadSegmentLimiter(private val maxDurationMs:Long=5000){
 fun shouldSplit(segment:VadAudioSegment)=segment.durationMs>=maxDurationMs
}