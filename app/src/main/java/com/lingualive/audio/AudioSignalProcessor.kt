package com.lingualive.audio

import kotlin.math.abs
import kotlin.math.max

/** Lightweight playback-audio conditioning: DC removal, peak protection and gentle gain. */
class AudioSignalProcessor(
    private val targetPeak: Double = 0.82,
    private val maxGain: Double = 3.0
) {
    private var dc = 0.0
    private var gain = 1.0

    fun process(input: ShortArray): ShortArray {
        if (input.isEmpty()) return input
        var sum = 0.0
        var peak = 0.0
        for (s in input) {
            val v = s / 32768.0
            sum += v
            peak = max(peak, abs(v))
        }
        val mean = sum / input.size
        dc = dc * 0.96 + mean * 0.04
        val desired = if (peak > 0.003) (targetPeak / peak).coerceIn(0.75, maxGain) else 1.0
        gain = gain * 0.85 + desired * 0.15
        return ShortArray(input.size) { i ->
            val normalized = (input[i] / 32768.0 - dc) * gain
            (normalized.coerceIn(-0.98, 0.98) * 32767.0).toInt().toShort()
        }
    }
}
