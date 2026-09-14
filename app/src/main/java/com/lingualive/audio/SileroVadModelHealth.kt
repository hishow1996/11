package com.lingualive.audio

data class SileroVadModelHealth(
    val status: SileroVadLoadStatus,
    val modelBytes: Long = 0L,
    val inferenceCount: Long = 0L,
    val lastProbability: Float = 0f
)
