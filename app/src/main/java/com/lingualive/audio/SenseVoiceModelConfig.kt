package com.lingualive.audio

data class SenseVoiceModelConfig(
    val modelPath: String,
    val tokensPath: String,
    val vadPath: String,
    val language: String = "auto",
    val useItn: Boolean = true,
    val sampleRate: Int = 16_000,
    val numThreads: Int = 1
)
