package com.lingualive.translate

class TranslationHub(
    private val translators: List<Translator>
) {

    suspend fun translate(
        text: String,
        source: String,
        target: String
    ): TranslationResult {
        val translator = translators.firstOrNull()
            ?: return TranslationResult(text, "No translator available")

        return translator.translate(text, source, target)
    }
}
