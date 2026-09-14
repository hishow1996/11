package com.lingualive.audio

object AudioFloatConverter {
    fun toFloat(samples: ShortArray): FloatArray {
        val out = FloatArray(samples.size)
        for (i in samples.indices) out[i] = samples[i] / 32768.0f
        return out
    }
}
