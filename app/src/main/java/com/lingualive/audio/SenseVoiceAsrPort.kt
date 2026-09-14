package com.lingualive.audio

interface SenseVoiceAsrPort {
    fun decode(samples: FloatArray, sampleRate: Int = 16_000): SenseVoiceAsrResult
    fun reset()
}
