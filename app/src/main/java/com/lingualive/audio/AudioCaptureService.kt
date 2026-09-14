package com.lingualive.audio

import android.app.Service
import android.content.Intent
import android.os.IBinder

/**
 * Foreground audio capture service foundation.
 *
 * Planned pipeline:
 * MediaProjection -> AudioPlaybackCapture -> AudioRecord -> ASR
 */
class AudioCaptureService : Service() {

    private var capturing = false

    override fun onCreate() {
        super.onCreate()
    }

    fun startCapture() {
        capturing = true
    }

    fun stopCapture() {
        capturing = false
    }

    fun isCapturing(): Boolean = capturing

    override fun onDestroy() {
        capturing = false
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
