package com.lingualive.audio
import android.media.AudioRecord
class PlaybackPcmReader(private val record:AudioRecord,private val onPcm:(ShortArray)->Unit){
 fun readOnce():Int{val b=ShortArray(512);val n=record.read(b,0,b.size);if(n>0)onPcm(b.copyOf(n));return n}
}