package com.lingualive.audio

class SileroVadInferenceAdapter(private val inference: SileroVadInferencePort) {
    fun reset() = inference.reset()
    fun process(samples: FloatArray): Float = inference.probability(samples).coerceIn(0f, 1f)
}