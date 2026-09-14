package com.lingualive.audio

import android.content.Context

object SileroVadAssetChecker {
    fun exists(context: Context, spec: SileroVadAssetSpec = SileroVadAssetSpec()): Boolean =
        runCatching { context.assets.open(spec.fileName).close(); true }.getOrDefault(false)
}
