package com.lingualive.audio
import android.os.Build
object PlaybackCaptureCompatibility {
    fun supported(): Boolean = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
}