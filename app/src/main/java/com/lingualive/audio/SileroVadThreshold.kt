package com.lingualive.audio

class SileroVadThreshold(private val start: Float = 0.5f, private val end: Float = 0.35f) {
    fun isSpeech(probability: Float, speaking: Boolean): Boolean =
        if (speaking) probability >= end else probability >= start
}