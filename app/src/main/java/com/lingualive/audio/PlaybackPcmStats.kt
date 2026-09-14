package com.lingualive.audio
data class PlaybackPcmStats(
    val rms: Float,
    val peak: Float,
    val samples: Int
)