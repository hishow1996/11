package com.lingualive.audio

/** Safe default until a network/local ASR implementation is selected. */
class NoOpAsrEngine : AsrEngine {
    override val id: String = "none"
    override suspend fun transcribe(audio: ShortArray, sampleRate: Int): AsrResult? = null
}
