package com.lingualive.audio

import java.io.File

data class LocalAsrBootstrapResult(
    val ready: Boolean,
    val reason: String,
    val model: LocalAsrModelFiles? = null
)

object LocalAsrBootstrap {
    fun inspect(modelRoot: File): LocalAsrBootstrapResult {
        if (!SherpaOnnxRuntimeGuard.isAvailable()) {
            return LocalAsrBootstrapResult(false, "sherpa_runtime_missing")
        }
        val model = LocalAsrAvailability.find(modelRoot)
            ?: return LocalAsrBootstrapResult(false, "model_files_missing")
        return LocalAsrBootstrapResult(true, "ready", model)
    }
}
