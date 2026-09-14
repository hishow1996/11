package com.lingualive.audio

import android.media.AudioRecord
import android.media.projection.MediaProjection

/**
 * System playback audio capture abstraction.
 *
 * Pipeline:
 * MediaProjection -> AudioPlaybackCapture -> AudioRecord -> AudioFrame
 */
class MediaProjectionAudioCapture {

    private var projection: MediaProjection? = null
    private var audioRecord: AudioRecord? = null

    fun setProjection(mediaProjection: MediaProjection) {
        projection = mediaProjection
    }

    fun start() {
        // AudioPlaybackCaptureConfiguration and AudioRecord
        // initialization are connected here.
    }

    fun stop() {
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
        projection?.stop()
        projection = null
    }
}
