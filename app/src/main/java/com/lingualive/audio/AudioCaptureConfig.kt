package com.lingualive.audio

data class AudioCaptureConfig(
    val sampleRate: Int = 16_000,
    val channelCount: Int = 1,
    val bitsPerSample: Int = 16,
    val chunkMs: Long = 250,
    val silenceThreshold: Double = 0.010,
    val silenceDurationMs: Long = 650,
    val preRollMs: Long = 300,
    val maxUtteranceMs: Long = 8_000
)
