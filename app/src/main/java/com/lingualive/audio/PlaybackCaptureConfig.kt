package com.lingualive.audio
data class PlaybackCaptureConfig(
    val sampleRate: Int = 16_000,
    val channelCount: Int = 1,
    val bufferMultiplier: Int = 2
)