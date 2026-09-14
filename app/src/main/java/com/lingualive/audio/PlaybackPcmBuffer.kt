package com.lingualive.audio
class PlaybackPcmBuffer(private val capacity:Int=32000){
 private val data=ShortArray(capacity); private var size=0
 @Synchronized fun append(input:ShortArray){val n=minOf(input.size,capacity-size);if(n>0){input.copyInto(data,size,0,n);size+=n}}
 @Synchronized fun drain():ShortArray{val out=data.copyOf(size);size=0;return out}
 @Synchronized fun clear(){size=0}
}