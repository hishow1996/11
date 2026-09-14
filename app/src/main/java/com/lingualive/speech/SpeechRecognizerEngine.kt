package com.lingualive.speech

import com.lingualive.audio.AudioFrame

interface SpeechRecognizerEngine {

    suspend fun process(frame: AudioFrame): String?

    fun release()
}
