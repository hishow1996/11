package com.lingualive.audio

import android.content.Context

object SileroVadModelBootstrap {
    fun ensure(context: Context, spec: SileroVadAssetSpec = SileroVadAssetSpec()): String? =
        runCatching { SileroVadAssetCopier.copyIfMissing(context, spec).absolutePath }.getOrNull()
}
