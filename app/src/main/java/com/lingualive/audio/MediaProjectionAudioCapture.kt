package com.lingualive.audio

import android.media.AudioRecord

/**
 * System audio capture adapter.
 *
 * Android 10+ can capture app playback audio through
 * MediaProjection + AudioPlaybackCaptureConfiguration.
 *
 * This class provides the capture abstraction used by the ASR pipeline.
 */
class MediaProjectionAudioCapture {

    private var audioRecord: AudioRecord? = null

    fun start() {
        // AudioRecord initialization will be connected after
        // MediaProjection permission flow is added.
    }

    fun stop() {
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
    }
}
