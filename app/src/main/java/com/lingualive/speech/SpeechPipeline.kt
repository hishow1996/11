package com.lingualive.speech

import com.lingualive.audio.AudioFrame

class SpeechPipeline(
    private var engine: SpeechRecognizerEngine
) {
    suspend fun process(frame: AudioFrame): SpeechResult {
        val text = engine.process(frame).orEmpty().trim()
        return SpeechResult(
            text = text,
            language = "auto",
            confidence = if (text.isEmpty()) 0f else 1f,
            timestamp = frame.timestamp,
            isFinal = text.isNotEmpty()
        )
    }

    fun changeEngine(newEngine: SpeechRecognizerEngine) {
        engine.release()
        engine = newEngine
    }

    fun release() = engine.release()
}
