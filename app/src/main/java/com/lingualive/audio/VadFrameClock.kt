package com.lingualive.audio

class VadFrameClock(private val sampleRate: Int = 16_000) {
    fun toMs(sample: Long): Long = sample * 1000L / sampleRate
}
