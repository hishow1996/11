package com.lingualive.audio

import android.content.Context
import java.io.File

class SileroVadModelRepository(private val context: Context) {
    fun modelFile(): File = SileroVadModelLocator.file(context)
    fun state(): SileroVadModelInstallState = SileroVadModelInspector.inspect(context)
}
