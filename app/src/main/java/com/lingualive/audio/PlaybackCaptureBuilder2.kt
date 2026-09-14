package com.lingualive.audio
import android.media.AudioRecord
import android.media.projection.MediaProjection
import android.os.Build
object PlaybackCaptureBuilder2 { fun create(projection:MediaProjection):AudioRecord? { if(Build.VERSION.SDK_INT<29)return null; return null } }