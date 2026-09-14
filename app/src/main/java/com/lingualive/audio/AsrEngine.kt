package com.lingualive.audio

interface AsrEngine {
    val id: String
    suspend fun transcribe(audio: ShortArray, sampleRate: Int): AsrResult?
}
