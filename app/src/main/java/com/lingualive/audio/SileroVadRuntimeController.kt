package com.lingualive.audio

class SileroVadRuntimeController(private val inference: SileroVadInferencePort) {
    private var state = SileroVadRuntimeState()
    fun status(): SileroVadRuntimeState = state
    fun reset() { inference.reset(); state = SileroVadRuntimeState(SileroVadInferenceStatus.READY) }
    fun score(samples: FloatArray): Float {
        val p = inference.probability(samples).coerceIn(0f, 1f)
        state = state.copy(lastProbability = p, processedSamples = state.processedSamples + samples.size)
        return p
    }
}
