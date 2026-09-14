package com.lingualive.audio
data class PlaybackCaptureStats(
    var capturedSamples: Long = 0,
    var droppedSamples: Long = 0,
    var readErrors: Long = 0
)