package com.lingualive.audio

data class SenseVoiceAsrMetrics(
    val calls: Long = 0L,
    val failures: Long = 0L,
    val lastLatencyMs: Long = 0L,
    val lastTextLength: Int = 0
)
