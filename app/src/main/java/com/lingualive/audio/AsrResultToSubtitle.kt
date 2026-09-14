package com.lingualive.audio

import com.lingualive.translation.TranslationInput

object AsrResultToSubtitle {
    fun map(result: AsrDecodeResult, startMs: Long, endMs: Long): TranslationInput? {
        val asr = result.result ?: return null
        val text = asr.text.trim()
        if (text.isEmpty()) return null
        return TranslationInput(text, asr.language, startMs, endMs)
    }
}
