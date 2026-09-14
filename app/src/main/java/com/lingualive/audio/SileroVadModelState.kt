package com.lingualive.audio
data class SileroVadModelState(val loaded:Boolean=false,val sampleRate:Int=16000,val frameSamples:Int=512,val lastProbability:Float=0f)