package com.lingualive.audio

import android.content.Context
import java.io.File

object SileroVadModelPathResolver {
    fun resolve(context: Context, spec: SileroVadAssetSpec = SileroVadAssetSpec()): File =
        File(context.filesDir, spec.fileName)
}
