package com.lingualive.audio
object PlaybackPcmAnalyzer {
    fun analyze(samples: FloatArray): PlaybackPcmStats {
        if (samples.isEmpty()) return PlaybackPcmStats(0f, 0f, 0)
        var sum = 0.0
        var peak = 0f
        for (v in samples) { sum += (v * v).toDouble(); peak = maxOf(peak, kotlin.math.abs(v)) }
        return PlaybackPcmStats(kotlin.math.sqrt(sum / samples.size).toFloat(), peak, samples.size)
    }
}