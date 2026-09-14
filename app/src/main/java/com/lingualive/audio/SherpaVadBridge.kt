package com.lingualive.audio

import java.io.File

/**
 * Keeps the app independent from a concrete sherpa-onnx AAR until the
 * selected runtime version is pinned. The actual Vad object is created by
 * the runtime adapter after readiness checks pass.
 */
class SherpaVadBridge(
    private val modelFile: File,
    private val parameters: VadParameters
) {
    fun ready(): Boolean =
        SherpaOnnxRuntimeGuard.isAvailable() &&
            modelFile.isFile &&
            modelFile.length() > 0L &&
            parameters.sampleRate == 16_000 &&
            parameters.windowSize > 0
}
