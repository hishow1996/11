package com.lingualive.audio
object VadAudioGate {
 fun rms(samples:FloatArray):Float{
  if(samples.isEmpty())return 0f
  var sum=0.0
  for(v in samples)sum+=(v*v).toDouble()
  return kotlin.math.sqrt(sum/samples.size).toFloat()
 }
 fun hasSpeech(samples:FloatArray,threshold:Float=0.003f)=rms(samples)>=threshold
}