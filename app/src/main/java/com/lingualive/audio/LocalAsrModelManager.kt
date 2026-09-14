package com.lingualive.audio

import android.content.Context
import java.io.File

class LocalAsrModelManager(private val context: Context) {
    val modelDir: File
        get() = File(context.getExternalFilesDir(null), "models/asr/sensevoice")

    fun inspect(): LocalAsrModelFiles? = LocalAsrAvailability.find(modelDir)

    fun status(): String = if (inspect() != null) "ready" else "missing"
}
