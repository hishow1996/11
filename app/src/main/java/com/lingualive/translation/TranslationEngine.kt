package com.lingualive.translation

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.concurrent.ConcurrentHashMap

class TranslationEngine(private val providers: Map<TranslationProviderId, TranslationProvider>) {
    private val cache = ConcurrentHashMap<String, String>()

    suspend fun translate(request: TranslationRequest, order: List<TranslationProviderId>, configs: Map<TranslationProviderId, ProviderConfig>): TranslationResponse = withContext(Dispatchers.IO) {
        val text = request.text.trim()
        require(text.isNotEmpty()) { "text is empty" }
        val key = "${request.sourceLanguage}|${request.targetLanguage}|$text"
        cache[key]?.let { return@withContext TranslationResponse(it, order.first(), true) }
        var last: Throwable? = null
        for (id in order.distinct()) {
            try {
                val provider = providers[id] ?: continue
                val result = provider.translate(request.copy(text = text), configs[id] ?: ProviderConfig()).trim()
                if (result.isNotEmpty()) {
                    cache[key] = result
                    return@withContext TranslationResponse(result, id)
                }
            } catch (error: Throwable) { last = error }
        }
        throw TranslationException("translation failed", last)
    }

    fun clearCache() = cache.clear()
}

object DefaultTranslationEngine {
    fun create(): TranslationEngine = TranslationEngine(mapOf(
        TranslationProviderId.OPENAI to OpenAiTranslationProvider(),
        TranslationProviderId.DEEPSEEK to DeepSeekTranslationProvider(),
        TranslationProviderId.DEEPL to DeepLTranslationProvider(),
        TranslationProviderId.GOOGLE to GoogleTranslationProvider(),
        TranslationProviderId.MICROSOFT to MicrosoftTranslationProvider(),
        TranslationProviderId.BAIDU to BaiduTranslationProvider(),
        TranslationProviderId.TENCENT to TencentTranslationProvider(),
        TranslationProviderId.MODERNMT to ModernMtTranslationProvider()
    ))
}
