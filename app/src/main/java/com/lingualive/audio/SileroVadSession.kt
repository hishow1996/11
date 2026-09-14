package com.lingualive.audio

class SileroVadSession(private val config: SileroVadConfig = SileroVadConfig()) {
    private var processedSamples = 0L
    fun reset() { processedSamples = 0L }
    fun nextStartSample(): Long = processedSamples
    fun advance(samples: Int) { processedSamples += samples }
    fun sampleRate(): Int = config.sampleRate
}