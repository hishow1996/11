package com.lingualive.audio
class VadFrameSplitter(private val frameSamples:Int=512){
 private var pending=FloatArray(0)
 fun push(input:FloatArray):List<FloatArray>{
  if(input.isEmpty())return emptyList()
  val merged=FloatArray(pending.size+input.size)
  pending.copyInto(merged);input.copyInto(merged,pending.size);pending=merged
  val out=ArrayList<FloatArray>()
  var offset=0
  while(pending.size-offset>=frameSamples){out.add(pending.copyOfRange(offset,offset+frameSamples));offset+=frameSamples}
  pending=pending.copyOfRange(offset,pending.size)
  return out
 }
 fun clear(){pending=FloatArray(0)}
}