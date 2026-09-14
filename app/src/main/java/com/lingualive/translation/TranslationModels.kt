package com.lingualive.translation

import java.util.Locale

enum class TranslationProviderId {
    OPENAI, DEEPSEEK, DEEPL, GOOGLE, MICROSOFT, BAIDU, TENCENT, MODERNMT
}

data class TranslationRequest(
    val text: String,
    val sourceLanguage: String = "auto",
    val targetLanguage: String = "zh-CN"
)

data class TranslationResponse(
    val text: String,
    val provider: TranslationProviderId,
    val cached: Boolean = false
)

data class ProviderConfig(
    val apiKey: String = "",
    val baseUrl: String = "",
    val model: String = ""
) {
    fun isConfigured(provider: TranslationProviderId): Boolean {
        val key = apiKey.trim()
        if (key.isEmpty()) return false
        return when (provider) {
            TranslationProviderId.BAIDU,
            TranslationProviderId.TENCENT -> key.substringBefore(':').isNotBlank() && key.substringAfter(':').isNotBlank()
            else -> true
        }
    }
}

fun normalizeLanguage(value: String): String = value.trim().replace('_', '-').ifEmpty { Locale.getDefault().language }
