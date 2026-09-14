package com.lingualive.audio
open class AudioPreprocessor(
    private val inputRate: Int,
    private val outputRate: Int = 16_000
) {
    private val dc = AudioDcBlocker()
    private val resampler = AudioFloatResampler(inputRate, outputRate)
    open fun process(input: FloatArray): FloatArray =
        if (input.isEmpty()) FloatArray(0) else resampler.resample(dc.process(input))
    open fun reset() { dc.reset() }
}