package com.lingualive.audio

class SileroVadProbabilityFilter(private val alpha: Float = 0.35f) {
    private var value = 0f
    fun filter(input: Float): Float {
        value += alpha.coerceIn(0f,1f) * (input.coerceIn(0f,1f) - value)
        return value
    }
    fun reset() { value = 0f }
}