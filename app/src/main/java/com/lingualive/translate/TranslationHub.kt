package com.lingualive.translate

class TranslationHub(
    private val translators: List<Translator>,
    private val cache: TranslationCache = TranslationCache()
) {
    suspend fun translate(
        text: String,
        source: String = "auto",
        target: String = "zh-CN",
        context: String? = null
    ): TranslationResult {
        require(text.isNotBlank()) { "text must not be blank" }

        cache.get(text, source, target)?.let { return it }

        var lastError: Throwable? = null
        for (translator in translators) {
            try {
                val result = translator.translate(text, source, target, context)
                if (result.translated.isNotBlank()) {
                    cache.put(text, source, target, result)
                    return result
                }
            } catch (error: Throwable) {
                lastError = error
            }
        }
        throw IllegalStateException("All configured translation engines failed", lastError)
    }

    fun clearCache() = cache.clear()
}
