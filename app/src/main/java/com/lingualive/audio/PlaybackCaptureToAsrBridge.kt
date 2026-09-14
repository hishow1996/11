package com.lingualive.audio
class PlaybackCaptureToAsrBridge(private val onAudio:suspend(FloatArray)->Unit){
 suspend fun submit(pcm:ShortArray){
  if(pcm.isEmpty())return
  val audio=FloatArray(pcm.size){pcm[it]/32768f}
  onAudio(audio)
 }
}