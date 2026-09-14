package com.lingualive.translate.engine

import com.lingualive.translate.TranslationResult
import com.lingualive.translate.Translator
import kotlin.system.measureTimeMillis

class DeepLTranslator(
    private val transport: suspend (String, String, String, String?, String) -> String,
    private val apiKey: () -> String
) : Translator {
    override val id = "deepl"
    override val displayName = "DeepL"

    override suspend fun translate(
        text: String, sourceLanguage: String, targetLanguage: String, context: String?
    ): TranslationResult {
        val key = apiKey().takeIf { it.isNotBlank() } ?: error("DeepL API key is missing")
        var output = ""
        val elapsed = measureTimeMillis {
            output = transport(text, sourceLanguage, targetLanguage, context, key)
        }
        return TranslationResult(text, output, id, elapsed)
    }
}
