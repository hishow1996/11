package com.lingualive.audio

class PlaybackCaptureToVAD(
    private val onSamples: suspend (FloatArray) -> Unit
) {
    suspend fun submit(pcm: FloatArray) {
        if (pcm.isNotEmpty()) onSamples(pcm)
    }
}