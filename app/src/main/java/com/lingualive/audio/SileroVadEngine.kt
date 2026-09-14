package com.lingualive.audio

import java.io.File

/**
 * VAD adapter. It validates the official sherpa-onnx runtime/model before
 * the native object is constructed.
 */
class SileroVadEngine(private val model: File, private val parameters: VadParameters) {
    fun isReady(): Boolean =
        SherpaOnnxRuntimeGuard.isAvailable() && model.isFile && model.length() > 0L

    fun reset() {
        // Native Vad reset is invoked by the concrete runtime adapter.
    }
}
