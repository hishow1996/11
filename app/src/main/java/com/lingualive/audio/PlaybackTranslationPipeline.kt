package com.lingualive.audio

class PlaybackTranslationPipeline(
    private val toVad: PlaybackCaptureToVAD
) {
    suspend fun submit(pcm: FloatArray) {
        if (pcm.isNotEmpty()) toVad.submit(pcm)
    }
}