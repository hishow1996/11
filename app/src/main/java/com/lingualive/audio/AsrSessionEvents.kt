package com.lingualive.audio

sealed class AsrSessionEvent {
    data object Started : AsrSessionEvent()
    data object Ready : AsrSessionEvent()
    data class Result(val text: String, val language: String, val startMs: Long, val endMs: Long) : AsrSessionEvent()
    data class Failed(val reason: String) : AsrSessionEvent()
    data object Stopped : AsrSessionEvent()
}
