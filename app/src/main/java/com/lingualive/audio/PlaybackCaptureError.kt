package com.lingualive.audio
sealed class PlaybackCaptureError {
    data object PermissionDenied : PlaybackCaptureError()
    data object Unsupported : PlaybackCaptureError()
    data object RecorderUnavailable : PlaybackCaptureError()
    data class Unknown(val message: String) : PlaybackCaptureError()
}