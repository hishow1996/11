package com.lingualive.capture

import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager

class MediaProjectionController(context: Context) {
    private val manager = context.getSystemService(MediaProjectionManager::class.java)

    fun createPermissionIntent(): Intent = manager.createScreenCaptureIntent()

    fun obtainProjection(resultCode: Int, data: Intent): MediaProjection =
        requireNotNull(manager.getMediaProjection(resultCode, data)) {
            "MediaProjection permission was not granted"
        }
}
