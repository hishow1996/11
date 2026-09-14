package com.lingualive.audio

data class SenseVoiceResult(
    val text: String,
    val language: String = "auto",
    val emotion: String = "",
    val event: String = "",
    val timestamps: List<Float> = emptyList()
)
