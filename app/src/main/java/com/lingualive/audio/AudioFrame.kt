package com.lingualive.audio

/**
 * Raw audio packet passed to speech recognition layer.
 */
data class AudioFrame(
    val samples: ShortArray,
    val sampleRate: Int,
    val timestamp: Long
)
