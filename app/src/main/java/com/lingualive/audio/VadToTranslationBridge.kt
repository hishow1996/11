package com.lingualive.audio

import com.lingualive.translation.TranslationInput

class VadToTranslationBridge(
    private val onInput: suspend (TranslationInput) -> Unit
) {
    suspend fun submit(asr: AsrDecodeResult, segment: VadAudioSegment) {
        val result = asr.result ?: return
        val text = result.text.trim()
        if (text.isEmpty()) return
        onInput(
            TranslationInput(
                text,
                result.language,
                segment.startSample * 1000L / 16_000L,
                segment.endSample * 1000L / 16_000L
            )
        )
    }
}
