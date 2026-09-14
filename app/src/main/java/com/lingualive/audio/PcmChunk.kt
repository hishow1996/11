package com.lingualive.audio

data class PcmChunk(
    val samples: ShortArray,
    val sampleRate: Int,
    val timestampMs: Long
)
