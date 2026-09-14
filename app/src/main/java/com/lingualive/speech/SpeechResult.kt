package com.lingualive.speech

/**
 * Result produced by speech recognition engines.
 */
data class SpeechResult(
    val text: String,
    val language: String = "auto",
    val confidence: Float = 0f,
    val timestamp: Long = System.currentTimeMillis()
)
