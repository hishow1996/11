package com.lingualive.translate.engine

import com.lingualive.translate.TranslationResult
import com.lingualive.translate.Translator
import kotlin.system.measureTimeMillis

/**
 * OpenAI-compatible DeepSeek adapter.
 * Network transport is injected so API credentials never live in the engine.
 */
class DeepSeekTranslator(
    private val transport: suspend (String, String, String, String?, String) -> String,
    private val apiKey: () -> String
) : Translator {
    override val id = "deepseek"
    override val displayName = "DeepSeek"

    override suspend fun translate(
        text: String, sourceLanguage: String, targetLanguage: String, context: String?
    ): TranslationResult {
        val key = apiKey().takeIf { it.isNotBlank() } ?: error("DeepSeek API key is missing")
        var output = ""
        val elapsed = measureTimeMillis {
            output = transport(text, sourceLanguage, targetLanguage, context, key)
        }
        return TranslationResult(text, output, id, elapsed)
    }
}
