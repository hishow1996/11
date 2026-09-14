package com.lingualive.audio

data class SileroVadDiagnostics(
    val modelLoaded: Boolean,
    val sampleRate: Int,
    val frameSamples: Int,
    val lastProbability: Float
)