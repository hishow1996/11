package com.lingualive.audio

data class AudioCaptureDiagnostics(
    val running: Boolean,
    val samplesCaptured: Long,
    val droppedSamples: Long,
    val lastRms: Double,
    val lastPeak: Double,
    val consecutiveErrors: Int
)
