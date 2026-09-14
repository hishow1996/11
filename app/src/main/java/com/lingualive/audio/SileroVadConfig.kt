package com.lingualive.audio
data class SileroVadConfig(
 val sampleRate:Int=16000,
 val threshold:Float=0.5f,
 val minSpeechMs:Long=250,
 val minSilenceMs:Long=350,
 val maxSpeechMs:Long=8000
)