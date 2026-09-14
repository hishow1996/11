package com.lingualive.audio
interface PlaybackCaptureSource {
    fun start(): Boolean
    fun stop()
    fun isRunning(): Boolean
}