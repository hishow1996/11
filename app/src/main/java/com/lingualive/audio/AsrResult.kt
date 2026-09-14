package com.lingualive.audio

data class AsrResult(
    val text: String,
    val language: String = "auto",
    val confidence: Float = 0f,
    val timestampMs: Long = System.currentTimeMillis()
)
