package com.lingualive.audio

import android.media.AudioAttributes
import android.media.AudioPlaybackCaptureConfiguration
import android.media.projection.MediaProjection

/**
 * Builds Android 10+ system audio capture configuration.
 */
class AudioPlaybackCapture {

    fun createConfiguration(
        projection: MediaProjection
    ): AudioPlaybackCaptureConfiguration {
        return AudioPlaybackCaptureConfiguration.Builder(projection)
            .addMatchingUsage(AudioAttributes.USAGE_MEDIA)
            .addMatchingUsage(AudioAttributes.USAGE_GAME)
            .build()
    }
}
