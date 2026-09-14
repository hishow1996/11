package com.lingualive.audio

object SileroVadInputNormalizer {
    fun normalize(samples: FloatArray): FloatArray = FloatArray(samples.size) { samples[it].coerceIn(-1f, 1f) }
}
