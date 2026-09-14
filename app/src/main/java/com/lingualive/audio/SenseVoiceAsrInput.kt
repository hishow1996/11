package com.lingualive.audio

object SenseVoiceAsrInput {
    fun normalize(samples: FloatArray): FloatArray {
        if (samples.isEmpty()) return samples
        return FloatArray(samples.size) { i -> samples[i].coerceIn(-1f, 1f) }
    }
}
