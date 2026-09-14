package com.lingualive.audio

class AudioCaptureRecovery(private val maxAttempts: Int = 3) {
    private var attempts = 0
    fun shouldRetry(): Boolean = ++attempts <= maxAttempts
    fun reset() { attempts = 0 }
}
