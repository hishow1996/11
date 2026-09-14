package com.lingualive.audio

import java.io.File

data class LocalAsrReadiness(
    val runtime: Boolean,
    val model: Boolean,
    val vad: Boolean,
    val supportedAbi: Boolean,
    val ready: Boolean
)

object LocalAsrReadinessChecker {
    fun check(root: File): LocalAsrReadiness {
        val runtime = SherpaOnnxRuntimeGuard.isAvailable()
        val files = ModelFileSet(root)
        val model = files.model.isFile && files.tokens.isFile
        val vad = files.vad.isFile
        val abi = LocalAsrDeviceProfileProvider.current().abi in
            setOf("arm64-v8a", "armeabi-v7a", "x86", "x86_64")
        return LocalAsrReadiness(runtime, model, vad, abi, runtime && model && vad && abi)
    }
}
