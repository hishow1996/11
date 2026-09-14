package com.lingualive.audio

object SherpaAudioPreprocessor {
    fun normalize(samples: ShortArray): FloatArray {
        val out = FloatArray(samples.size)
        var peak = 0f
        for (s in samples) peak = maxOf(peak, kotlin.math.abs(s / 32768f))
        val gain = if (peak in 0.0001f..0.98f) (0.85f / peak).coerceAtMost(2.0f) else 1f
        for (i in samples.indices) out[i] = (samples[i] / 32768f * gain).coerceIn(-1f, 1f)
        return out
    }
}
