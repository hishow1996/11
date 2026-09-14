package com.lingualive.translate

class TranslationHub(
    private val translators: List<Translator>
) {
    suspend fun translate(
        text: String,
        source: String = "auto",
        target: String = "zh-CN",
        context: String? = null
    ): TranslationResult {
        require(text.isNotBlank()) { "text must not be blank" }
        var lastError: Throwable? = null
        for (translator in translators) {
            try {
                return translator.translate(text, source, target, context)
            } catch (error: Throwable) {
                lastError = error
            }
        }
        throw IllegalStateException("All configured translation engines failed", lastError)
    }
}
