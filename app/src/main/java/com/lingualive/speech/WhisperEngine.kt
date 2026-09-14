package com.lingualive.speech

import com.lingualive.audio.AudioFrame

/**
 * Whisper based local speech recognition engine.
 * Native whisper.cpp/ONNX backend will be connected here.
 */
class WhisperEngine : SpeechRecognizerEngine {

    override suspend fun recognize(audio: AudioFrame): SpeechResult {
        // TODO connect whisper.cpp Android native backend
        return SpeechResult(
            text = "",
            language = "unknown",
            confidence = 0f
        )
    }

    override fun release() {
        // release native model resources
    }
}
