package com.lingualive.audio

data class SpeechChunkTimestamp(
    val startMs: Long,
    val endMs: Long,
    val sampleCount: Int
)
