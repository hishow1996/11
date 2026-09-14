package com.lingualive.audio

object SenseVoiceResultAdapter {
    fun toAsr(result: SenseVoiceResult): AsrResult? {
        val text = result.text.replace(Regex("\\s+"), " ").trim()
        return if (text.isEmpty()) null else AsrResult(text = text, language = result.language)
    }
}
