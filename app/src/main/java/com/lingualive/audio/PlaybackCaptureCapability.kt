package com.lingualive.audio
import android.os.Build
object PlaybackCaptureCapability { fun supported():Boolean=Build.VERSION.SDK_INT>=29 }