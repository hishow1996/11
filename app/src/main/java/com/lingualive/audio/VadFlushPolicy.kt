package com.lingualive.audio

data class VadFlushPolicy(
    val flushOnStop: Boolean = true,
    val flushOnAudioGap: Boolean = true,
    val maxSpeechMs: Long = 8_000
)
