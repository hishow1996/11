package com.lingualive.audio
sealed class PlaybackCaptureResult {
    data object Started : PlaybackCaptureResult()
    data object Stopped : PlaybackCaptureResult()
    data class Error(val error: PlaybackCaptureError) : PlaybackCaptureResult()
}