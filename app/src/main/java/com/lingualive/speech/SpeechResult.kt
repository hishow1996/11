package com.lingualive.speech

data class SpeechResult(
    val text: String,
    val language: String = "auto",
    val confidence: Float = 0f,
    val startTimeMs: Long = 0L,
    val endTimeMs: Long = 0L,
    val timestamp: Long = System.currentTimeMillis(),
    val isFinal: Boolean = true
)
