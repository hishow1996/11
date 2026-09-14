package com.lingualive.translate

interface Translator {
    suspend fun translate(
        text: String,
        sourceLanguage: String = "auto",
        targetLanguage: String = "zh-CN"
    ): TranslationResult
}

data class TranslationResult(
    val original: String,
    val translated: String,
    val engine: String
)
