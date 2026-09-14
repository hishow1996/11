package com.lingualive.audio

class VadSpeechDurationCalculator(private val sampleRate: Int = 16_000) {
    fun toMs(samples: Long): Long = samples * 1000L / sampleRate
}