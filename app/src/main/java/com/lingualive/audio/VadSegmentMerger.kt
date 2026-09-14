package com.lingualive.audio
class VadSegmentMerger(private val maxGapMs:Long=300,private val sampleRate:Int=16000){
 fun canMerge(previous:VadAudioSegment,next:VadAudioSegment):Boolean{
  val gap=(next.startSample-previous.endSample)*1000L/sampleRate
  return gap in 0..maxGapMs
 }
}