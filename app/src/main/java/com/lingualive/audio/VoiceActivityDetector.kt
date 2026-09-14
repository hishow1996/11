package com.lingualive.audio

import kotlin.math.sqrt

/** RMS VAD with adaptive noise floor and silence hysteresis for noisy media streams. */
class VoiceActivityDetector(
    private val silenceThreshold: Double = 0.010,
    private val silenceDurationMs: Long = 650
) {
    private var silentMs = 0L
    private var noiseFloor = 0.0035

    fun hasVoice(samples: ShortArray, sampleRate: Int = 16_000): Boolean {
        if (samples.isEmpty()) return false
        var sum = 0.0
        var peak = 0.0
        for (sample in samples) {
            val normalized = sample / 32768.0
            sum += normalized * normalized
            peak = maxOf(peak, kotlin.math.abs(normalized))
        }
        val rms = sqrt(sum / samples.size)
        if (rms < silenceThreshold * 1.35) noiseFloor = noiseFloor * 0.92 + rms * 0.08
        val dynamicThreshold = maxOf(silenceThreshold, noiseFloor * 2.8)
        val speech = rms >= dynamicThreshold || peak >= dynamicThreshold * 3.2
        val duration = samples.size * 1000L / sampleRate
        if (speech) silentMs = 0L else silentMs += duration
        return speech || silentMs < silenceDurationMs
    }

    fun reset() {
        silentMs = 0L
        noiseFloor = 0.0035
    }
}
