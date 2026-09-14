package com.lingualive.translation

data class TranslationInput(val text: String, val sourceLanguage: String, val startMs: Long, val endMs: Long)
