package com.lingualive.audio

class AudioGapDetector(private val maxGapMs: Long = 500) {
    private var lastTimestamp = 0L
    fun gapDetected(timestampMs: Long): Boolean {
        val gap = if (lastTimestamp == 0L) false else timestampMs - lastTimestamp > maxGapMs
        lastTimestamp = timestampMs
        return gap
    }
    fun reset() { lastTimestamp = 0L }
}
