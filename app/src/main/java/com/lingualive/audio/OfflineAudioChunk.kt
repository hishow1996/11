package com.lingualive.audio

data class OfflineAudioChunk(val samples: FloatArray, val sampleRate: Int, val startMs: Long) {
    fun valid() = samples.isNotEmpty() && sampleRate == 16_000
}
