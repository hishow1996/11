package com.lingualive.translation

data class TranslationSegment(
    val source: String,
    val translated: String,
    val startMs: Long,
    val endMs: Long,
    val language: String = "auto"
)
