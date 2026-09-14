package com.lingualive.audio

import android.content.Context

object SileroVadModelInspector {
    fun inspect(context: Context): SileroVadModelInstallState =
        if (!SileroVadModelLocator.exists(context)) SileroVadModelInstallState.MISSING
        else SileroVadModelInstallState.READY
}
