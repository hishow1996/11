package com.lingualive.speech

import com.lingualive.audio.AudioFrame

class SpeechPipeline(
    private var engine: SpeechRecognizerEngine
) {
    suspend fun process(frame: AudioFrame): SpeechResult =
        engine.recognize(frame)

    fun changeEngine(newEngine: SpeechRecognizerEngine) {
        engine.release()
        engine = newEngine
    }

    fun release() = engine.release()
}
