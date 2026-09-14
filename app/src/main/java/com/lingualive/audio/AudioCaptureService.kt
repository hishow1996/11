package com.lingualive.audio

import android.app.Service
import android.content.Intent
import android.os.IBinder

/**
 * Foreground service entry for long running live translation capture.
 * Pipeline:
 * MediaProjection -> AudioPlaybackCapture -> AudioRecord -> ASR
 */
class AudioCaptureService : Service() {

    private var running = false

    override fun onCreate() {
        super.onCreate()
        running = true
    }

    fun startCapture() {
        running = true
    }

    fun stopCapture() {
        running = false
    }

    fun isRunning(): Boolean = running

    override fun onDestroy() {
        running = false
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
