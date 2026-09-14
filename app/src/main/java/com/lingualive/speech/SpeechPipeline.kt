package com.lingualive.speech

import com.lingualive.audio.AudioFrame

/**
 * Connects audio frames with speech recognition engines.
 */
class SpeechPipeline(
    private var engine: SpeechRecognizerEngine
) {

    suspend fun process(frame: AudioFrame): SpeechResult {
        return engine.recognize(frame)
    }

    fun changeEngine(newEngine: SpeechRecognizerEngine) {
        engine.release()
        engine = newEngine
    }

    fun release() {
        engine.release()
    }
}
