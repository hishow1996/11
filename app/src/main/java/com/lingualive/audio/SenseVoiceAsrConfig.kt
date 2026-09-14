package com.lingualive.audio

data class SenseVoiceAsrConfig(
    val modelPath: String,
    val tokensPath: String,
    val language: String = "auto",
    val sampleRate: Int = 16_000,
    val numThreads: Int = 2,
    val useInverseTextNormalization: Boolean = true,
    val provider: String = "cpu"
)
