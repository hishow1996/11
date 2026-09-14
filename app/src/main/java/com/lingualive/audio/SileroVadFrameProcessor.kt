package com.lingualive.audio

class SileroVadFrameProcessor(private val threshold: SileroVadThreshold = SileroVadThreshold()) {
    private var speaking = false
    fun process(frame: VadFrameModel, probability: Float): SileroVadResultModel {
        speaking = threshold.isSpeech(probability, speaking)
        return SileroVadResultModel(speaking, probability.coerceIn(0f,1f), frame.startSample, frame.endSample)
    }
    fun reset(){ speaking=false }
}