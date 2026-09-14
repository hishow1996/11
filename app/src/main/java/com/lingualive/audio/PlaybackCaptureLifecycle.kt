package com.lingualive.audio
interface PlaybackCaptureLifecycle {
    fun onStarted()
    fun onStopped()
    fun onError(error: PlaybackCaptureError)
}