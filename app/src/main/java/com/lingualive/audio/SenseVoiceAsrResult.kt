package com.lingualive.audio

data class SenseVoiceAsrResult(
    val text: String,
    val language: String = "",
    val emotion: String = "",
    val event: String = "",
    val durationMs: Long = 0L
)
