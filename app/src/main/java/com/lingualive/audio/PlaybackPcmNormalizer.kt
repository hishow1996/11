package com.lingualive.audio

object PlaybackPcmNormalizer {
    fun normalize(input: ShortArray): FloatArray {
        val out = FloatArray(input.size)
        for (i in input.indices) out[i] = input[i] / 32768f
        return out
    }
}