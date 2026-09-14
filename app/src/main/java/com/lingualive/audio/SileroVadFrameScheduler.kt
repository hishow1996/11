package com.lingualive.audio

class SileroVadFrameScheduler(private val frameSamples: Int = 512) {
    private var sampleCursor = 0L
    fun next(samples: FloatArray): VadFrameModel {
        val frame = VadFrameModel(samples, sampleCursor, sampleCursor + samples.size)
        sampleCursor += samples.size
        return frame
    }
    fun reset() { sampleCursor = 0L }
}