package com.lingualive.audio

class SileroVadFrameRunner(private val inference: SileroVadInferencePort) {
    private val buffer = SileroVadFrameBuffer()
    fun process(input: FloatArray, onProbability: (Float) -> Unit) {
        for (frame in buffer.push(input)) onProbability(inference.probability(frame).coerceIn(0f, 1f))
    }
    fun reset() { buffer.clear(); inference.reset() }
}
