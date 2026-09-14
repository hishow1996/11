package com.lingualive.audio

import com.lingualive.translation.TranslationInput

object AsrToTranslationMapper {
    fun map(result: AsrDecodeResult, startMs: Long, endMs: Long): TranslationInput? {
        val r = result.result ?: return null
        val text = r.text.trim()
        if (text.isEmpty()) return null
        return TranslationInput(text, r.language, startMs, endMs)
    }
}
