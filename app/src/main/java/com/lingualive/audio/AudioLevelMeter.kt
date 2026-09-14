package com.lingualive.audio

import kotlin.math.sqrt

/** Rolling audio level for UI diagnostics and automatic capture health checks. */
class AudioLevelMeter(private val smoothing: Double = 0.18) {
    @Volatile var rms: Double = 0.0
        private set
    @Volatile var peak: Double = 0.0
        private set

    fun update(samples: ShortArray) {
        if (samples.isEmpty()) return
        var sum = 0.0
        var p = 0.0
        for (s in samples) {
            val v = s / 32768.0
            sum += v * v
            val a = kotlin.math.abs(v)
            if (a > p) p = a
        }
        val current = sqrt(sum / samples.size)
        rms = rms * (1.0 - smoothing) + current * smoothing
        peak = peak * (1.0 - smoothing) + p * smoothing
    }

    fun reset() {
        rms = 0.0
        peak = 0.0
    }
}
