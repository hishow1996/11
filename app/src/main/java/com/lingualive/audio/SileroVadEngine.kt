package com.lingualive.audio

import java.io.File

class SileroVadEngine(
    private val model: File?,
    private val parameters: VadParameters,
    private val inference: SileroVadInferencePort? = null
) {
    constructor(inference: SileroVadInferencePort) : this(null, VadParameters(), inference)

    fun isReady(): Boolean = inference != null || (
        model != null &&
            SherpaOnnxRuntimeGuard.isAvailable() &&
            model.isFile &&
            model.length() > 0L
        )

    fun probability(samples: FloatArray): Float =
        inference?.probability(samples)?.coerceIn(0f, 1f) ?: 0f

    fun reset() {
        inference?.reset()
    }
}
