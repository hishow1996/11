package com.lingualive.audio

class PlaybackCaptureSession {
    private var active = false
    fun start() { check(!active); active = true }
    fun stop() { active = false }
    fun isActive() = active
}
