package com.lingualive.audio

import kotlin.math.sqrt

/** Lightweight RMS-based VAD with silence hysteresis for live ASR. */
class VoiceActivityDetector(
    private val silenceThreshold: Double = 0.012,
    private val silenceDurationMs: Long = 650
) {
    private var silentMs = 0L

    fun hasVoice(samples: ShortArray, sampleRate: Int = 16_000): Boolean {
        if (samples.isEmpty()) return false
        var sum = 0.0
        for (sample in samples) {
            val normalized = sample / 32768.0
            sum += normalized * normalized
        }
        val rms = sqrt(sum / samples.size)
        val speech = rms >= silenceThreshold
        val duration = samples.size * 1000L / sampleRate
        if (speech) silentMs = 0L else silentMs += duration
        return speech || silentMs < silenceDurationMs
    }

    fun reset() { silentMs = 0L }
}
