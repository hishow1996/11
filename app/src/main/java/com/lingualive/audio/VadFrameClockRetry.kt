package com.lingualive.audio
class VadFrameClockRetry(private val sampleRate:Int=16000){fun toMs(sample:Long)=sample*1000L/sampleRate}