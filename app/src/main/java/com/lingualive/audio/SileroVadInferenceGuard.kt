package com.lingualive.audio

class SileroVadInferenceGuard(private val delegate: SileroVadInferencePort) : SileroVadInferencePort {
    override fun probability(samples: FloatArray): Float {
        if (samples.isEmpty()) return 0f
        return runCatching { delegate.probability(samples) }.getOrDefault(0f).coerceIn(0f, 1f)
    }
    override fun reset() { runCatching { delegate.reset() } }
}
