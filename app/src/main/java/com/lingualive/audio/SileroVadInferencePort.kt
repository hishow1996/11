package com.lingualive.audio

interface SileroVadInferencePort {
    fun probability(samples: FloatArray): Float
    fun reset()
}