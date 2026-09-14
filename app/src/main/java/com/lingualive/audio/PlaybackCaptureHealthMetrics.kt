package com.lingualive.audio

data class PlaybackCaptureHealthMetrics(
    val frames: Long = 0,
    val dropped: Long = 0,
    val errors: Long = 0,
    val silentFrames: Long = 0
)