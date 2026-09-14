package com.lingualive.translation

data class TranslationSubtitleBridge(
    val source: String,
    val translated: String,
    val startMs: Long,
    val endMs: Long,
    val sourceLanguage: String = "auto",
    val targetLanguage: String
)
