package com.lingualive.audio

class SileroVadInferenceThreading(private val delegate: SileroVadInferencePort) : SileroVadInferencePort {
    @Synchronized override fun probability(samples: FloatArray): Float = delegate.probability(samples).coerceIn(0f, 1f)
    @Synchronized override fun reset() = delegate.reset()
}
