package com.lingualive.audio

class SherpaOnnxVadSession(private val inference: SherpaOnnxVadInference) {
    fun accept(samples: FloatArray): Float {
        if (samples.isEmpty()) return 0f
        inference.acceptWaveform(samples)
        return inference.probability(samples)
    }

    fun speechDetected(): Boolean = inference.isSpeechDetected()

    fun reset() = inference.reset()

    fun release() = inference.release()
}
