package com.lingualive.audio
import android.media.projection.MediaProjection
class PlaybackProjectionController(private val onStopped:()->Unit): MediaProjection.Callback() {
 override fun onStop(){ onStopped() }
}