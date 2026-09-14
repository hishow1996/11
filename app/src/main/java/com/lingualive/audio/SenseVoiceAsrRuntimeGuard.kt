package com.lingualive.audio

object SenseVoiceAsrRuntimeGuard {
    fun isAvailable(): Boolean = runCatching {
        Class.forName("com.k2fsa.sherpa.onnx.OfflineRecognizer")
        true
    }.getOrDefault(false)
}
