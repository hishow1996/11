package com.lingualive.audio

data class PlaybackCaptureRequest(
    val sampleRate: Int = 16_000,
    val channelCount: Int = 1,
    val requireConsent: Boolean = true
)
