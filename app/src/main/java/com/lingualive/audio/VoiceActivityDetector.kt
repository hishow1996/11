package com.lingualive.audio

/**
 * Simple VAD layer to remove silence before ASR processing.
 */
class VoiceActivityDetector(
    private val threshold: Double = 500.0
) {

    fun hasVoice(samples: ShortArray): Boolean {
        if (samples.isEmpty()) return false

        var sum = 0.0
        samples.forEach {
            sum += kotlin.math.abs(it.toInt())
        }

        val average = sum / samples.size
        return average > threshold
    }
}
