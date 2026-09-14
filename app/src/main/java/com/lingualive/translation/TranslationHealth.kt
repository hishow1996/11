package com.lingualive.translation

data class TranslationHealth(
    val requests: Long = 0,
    val failures: Long = 0,
    val cacheHits: Long = 0,
    val lastLatencyMs: Long = 0
)
