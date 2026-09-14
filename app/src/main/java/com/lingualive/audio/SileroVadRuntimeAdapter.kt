package com.lingualive.audio

class SileroVadRuntimeAdapter(private val inference: SileroVadInferencePort) : SileroVadInferencePort {
    override fun probability(samples: FloatArray): Float = inference.probability(samples).coerceIn(0f, 1f)
    override fun reset() = inference.reset()
}
