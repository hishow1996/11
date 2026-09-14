package com.lingualive.audio

data class SileroVadModelConfig(
    val modelPath: String,
    val sampleRate: Int = 16_000,
    val windowSamples: Int = 512,
    val threshold: Float = 0.25f,
    val minSilenceDurationSec: Float = 0.5f,
    val minSpeechDurationSec: Float = 0.2f,
    val maxSpeechDurationSec: Float = 10f,
    val numThreads: Int = 1
)
