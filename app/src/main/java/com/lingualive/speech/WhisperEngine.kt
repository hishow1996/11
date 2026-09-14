package com.lingualive.speech

import com.lingualive.audio.AudioFrame

class WhisperEngine : SpeechRecognizerEngine {
    override suspend fun process(frame: AudioFrame): String? = null

    override fun release() {
    }
}
