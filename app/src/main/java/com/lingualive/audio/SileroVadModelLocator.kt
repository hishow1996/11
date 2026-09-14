package com.lingualive.audio

import android.content.Context
import java.io.File

object SileroVadModelLocator {
    private const val MODEL_NAME = "silero_vad.onnx"

    fun file(context: Context): File = File(context.filesDir, "models/$MODEL_NAME")
    fun exists(context: Context): Boolean = file(context).isFile && file(context).length() > 0
}
