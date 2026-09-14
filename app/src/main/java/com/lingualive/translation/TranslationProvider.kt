package com.lingualive.translation

interface TranslationProvider {
    val id: TranslationProviderId
    suspend fun translate(request: TranslationRequest, config: ProviderConfig): String
}

class TranslationException(message: String, cause: Throwable? = null) : Exception(message, cause)
