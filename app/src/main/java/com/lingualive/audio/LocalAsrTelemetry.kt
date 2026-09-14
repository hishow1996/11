package com.lingualive.audio

data class LocalAsrTelemetry(
    var utterances: Long = 0,
    var successful: Long = 0,
    var empty: Long = 0,
    var failed: Long = 0,
    var fallback: Long = 0
)
