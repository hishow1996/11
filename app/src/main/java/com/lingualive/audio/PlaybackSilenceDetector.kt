package com.lingualive.audio

class PlaybackSilenceDetector(private val threshold: Float = 0.003f) {
    fun isSilent(samples: FloatArray): Boolean =
        !VadAudioGate.hasSpeech(samples, threshold)
}
