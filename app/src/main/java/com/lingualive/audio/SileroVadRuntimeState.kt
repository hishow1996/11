package com.lingualive.audio

data class SileroVadRuntimeState(
    val status: SileroVadInferenceStatus = SileroVadInferenceStatus.UNINITIALIZED,
    val lastProbability: Float = 0f,
    val processedSamples: Long = 0L
)
