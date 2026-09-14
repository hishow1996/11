package com.lingualive.audio

import android.content.Context
import java.io.File

object SileroVadModelCopy {
    fun copyFromAssets(context: Context, assetName: String = "silero_vad.onnx"): File {
        val target = SileroVadModelLocator.file(context)
        if (target.isFile && target.length() > 0) return target
        target.parentFile?.mkdirs()
        context.assets.open(assetName).use { input ->
            target.outputStream().use { output -> input.copyTo(output) }
        }
        return target
    }
}
