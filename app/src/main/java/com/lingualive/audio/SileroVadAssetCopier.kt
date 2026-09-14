package com.lingualive.audio

import android.content.Context
import java.io.File

object SileroVadAssetCopier {
    fun copyIfMissing(context: Context, spec: SileroVadAssetSpec = SileroVadAssetSpec()): File {
        val target = File(context.filesDir, spec.fileName)
        if (!target.exists() || target.length() == 0L) {
            context.assets.open(spec.fileName).use { input ->
                target.outputStream().use { output -> input.copyTo(output) }
            }
        }
        return target
    }
}
