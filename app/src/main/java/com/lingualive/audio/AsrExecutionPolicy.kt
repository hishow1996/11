package com.lingualive.audio

data class AsrExecutionPolicy(
    val maxUtteranceMs: Long = 8_000,
    val maxInferenceMs: Long = 6_000,
    val minAudioSamples: Int = 2_400
)
