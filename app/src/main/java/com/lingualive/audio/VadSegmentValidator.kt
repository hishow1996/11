package com.lingualive.audio
object VadSegmentValidator{fun valid(segment:VadAudioSegment,sampleRate:Int=16000)=segment.samples.isNotEmpty()&&segment.endSample>segment.startSample&&sampleRate>0}