package com.lingualive.translate

interface Translator {
    val id: String
    val displayName: String

    suspend fun translate(
        text: String,
        sourceLanguage: String = "auto",
        targetLanguage: String = "zh-CN",
        context: String? = null
    ): TranslationResult
}

data class TranslationResult(
    val original: String,
    val translated: String,
    val engine: String,
    val latencyMs: Long = 0L,
    val cached: Boolean = false
)
