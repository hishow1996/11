package com.lingualive.audio
class AudioFloatResampler(private val inputRate:Int,private val outputRate:Int){
 fun resample(input:FloatArray):FloatArray{if(inputRate==outputRate)return input.copyOf();if(input.isEmpty())return FloatArray(0);val n=(input.size.toDouble()*outputRate/inputRate).toInt().coerceAtLeast(1);val out=FloatArray(n);for(i in out.indices){val pos=i.toDouble()*inputRate/outputRate;val a=pos.toInt().coerceIn(0,input.lastIndex);val b=(a+1).coerceAtMost(input.lastIndex);val f=(pos-a).toFloat();out[i]=input[a]*(1-f)+input[b]*f};return out}
}