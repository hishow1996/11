package com.lingualive.audio

data class VadParameters(
    val sampleRate: Int = 16_000,
    val threshold: Float = 0.5f,
    val minSilenceDurationSec: Float = 0.25f,
    val minSpeechDurationSec: Float = 0.25f,
    val maxSpeechDurationSec: Float = 8.0f,
    val windowSize: Int = 512
)
