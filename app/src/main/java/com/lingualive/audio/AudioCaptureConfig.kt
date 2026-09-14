package com.lingualive.audio

data class AudioCaptureConfig(
    val sampleRate: Int = 16_000,
    val channelCount: Int = 1,
    val bitsPerSample: Int = 16,
    val chunkMs: Long = 320,
    val silenceThreshold: Double = 0.012,
    val silenceDurationMs: Long = 650
)
