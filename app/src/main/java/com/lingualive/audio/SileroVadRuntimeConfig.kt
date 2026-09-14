package com.lingualive.audio

data class SileroVadRuntimeConfig(
    val modelPath: String,
    val sampleRate: Int = 16_000,
    val windowSize: Int = 512,
    val threshold: Float = 0.25f,
    val minSilenceSeconds: Float = 0.5f,
    val minSpeechSeconds: Float = 0.2f,
    val maxSpeechSeconds: Float = 10f,
    val numThreads: Int = 1
)
