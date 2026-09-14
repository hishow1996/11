package com.lingualive.translation

data class TranslationOutput(
    val source: String,
    val translated: String,
    val sourceLanguage: String,
    val targetLanguage: String,
    val startMs: Long,
    val endMs: Long
)
