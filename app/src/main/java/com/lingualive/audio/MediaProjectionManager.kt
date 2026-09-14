package com.lingualive.audio

import android.media.projection.MediaProjection

/**
 * Holds MediaProjection instance used for system playback capture.
 */
class MediaProjectionManager {

    private var projection: MediaProjection? = null

    fun setProjection(value: MediaProjection) {
        projection = value
    }

    fun getProjection(): MediaProjection? = projection

    fun release() {
        projection?.stop()
        projection = null
    }
}
