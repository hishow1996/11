package com.lingualive.audio
class PlaybackSilenceDetectorRetry(private val threshold:Float=0.003f){fun isSilent(samples:FloatArray)=!VadAudioGate.hasSpeech(samples,threshold)}