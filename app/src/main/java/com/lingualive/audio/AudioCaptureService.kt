package com.lingualive.audio

import android.app.Service
import android.content.Intent
import android.os.IBinder

/**
 * Background audio capture service.
 * Future implementation will use MediaProjection and AudioPlaybackCapture.
 */
class AudioCaptureService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
    }
}
