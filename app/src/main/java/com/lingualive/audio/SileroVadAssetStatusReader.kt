package com.lingualive.audio

import android.content.Context
import java.io.File

object SileroVadAssetStatusReader {
    fun read(context: Context, spec: SileroVadAssetSpec = SileroVadAssetSpec()): SileroVadAssetStatus {
        val file = File(context.filesDir, spec.fileName)
        return SileroVadAssetStatus(file.isFile, if (file.isFile) file.length() else 0L, file.absolutePath)
    }
}
