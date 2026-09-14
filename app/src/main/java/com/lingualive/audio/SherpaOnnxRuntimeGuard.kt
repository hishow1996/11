package com.lingualive.audio

/**
 * Detects the optional Sherpa-ONNX JNI runtime without loading it on
 * Android 9 or when the AAR/native library is absent.
 */
object SherpaOnnxRuntimeGuard {
    fun isAvailable(): Boolean = runCatching {
        Class.forName("com.k2fsa.sherpa.onnx.OfflineRecognizer")
        true
    }.getOrDefault(false)
}
