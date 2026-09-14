package com.lingualive.audio

enum class PlaybackCaptureMode {
    PLAYBACK_CAPTURE,
    MICROPHONE_FALLBACK
}

object PlaybackCaptureFallback {
    fun mode(apiLevel: Int): PlaybackCaptureMode =
        if (apiLevel >= 29) PlaybackCaptureMode.PLAYBACK_CAPTURE
        else PlaybackCaptureMode.MICROPHONE_FALLBACK
}
