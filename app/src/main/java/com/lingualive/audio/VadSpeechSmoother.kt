package com.lingualive.audio
class VadSpeechSmoother(private val requiredFrames:Int=3){
 private var positive=0
 private var negative=0
 fun update(speech:Boolean):Boolean{
  if(speech){positive++;negative=0}else{negative++;positive=0}
  return if(speech)positive>=requiredFrames else negative>=requiredFrames
 }
 fun reset(){positive=0;negative=0}
}