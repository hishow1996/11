package com.lingualive.audio

import android.content.Context

object SherpaOnnxRuntimeStatusProvider {
    fun get(context: Context): SherpaOnnxRuntimeStatus {
        val jni = SherpaOnnxRuntimeGuard.isAvailable()
        val model = SileroVadModelLocator.exists(context)
        return SherpaOnnxRuntimeStatus(jniAvailable = jni, modelAvailable = model, ready = jni && model)
    }
}
