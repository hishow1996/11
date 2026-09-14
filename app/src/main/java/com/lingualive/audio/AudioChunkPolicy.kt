package com.lingualive.audio

class AudioChunkPolicy(
    private val minSamples: Int = 2400,
    private val maxSamples: Int = 12800
) {
    fun normalize(input: ShortArray): ShortArray? {
        if (input.size < minSamples) return null
        return if (input.size <= maxSamples) input else input.copyOf(maxSamples)
    }
}
