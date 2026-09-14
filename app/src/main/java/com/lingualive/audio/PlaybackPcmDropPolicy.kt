package com.lingualive.audio
class PlaybackPcmDropPolicy(private val maxQueueSamples: Int = 64_000) {
    fun shouldDrop(queueSamples: Int): Boolean = queueSamples > maxQueueSamples
}