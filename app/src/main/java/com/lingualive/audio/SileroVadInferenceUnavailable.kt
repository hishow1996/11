package com.lingualive.audio

class SileroVadInferenceUnavailable : SileroVadInferencePort {
    override fun probability(samples: FloatArray): Float = 0f
    override fun reset() = Unit
}
