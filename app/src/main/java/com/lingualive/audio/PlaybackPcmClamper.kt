package com.lingualive.audio
object PlaybackPcmClamper {
    fun clamp(samples: FloatArray): FloatArray =
        FloatArray(samples.size) { samples[it].coerceIn(-1f, 1f) }
}