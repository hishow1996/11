package com.lingualive.audio

import java.io.File

object SherpaOnnxVadFactory {
    fun create(modelFile: File, parameters: VadParameters = VadParameters()): SherpaOnnxVadInference? {
        if (!SherpaOnnxRuntimeGuard.isAvailable()) return null
        if (!modelFile.isFile || modelFile.length() <= 0L) return null
        val config = SileroVadModelConfig(
            modelPath = modelFile.absolutePath,
            sampleRate = parameters.sampleRate,
            windowSamples = parameters.windowSize,
            threshold = parameters.threshold,
            minSilenceDurationSec = parameters.minSilenceDurationSec,
            minSpeechDurationSec = parameters.minSpeechDurationSec,
            maxSpeechDurationSec = parameters.maxSpeechDurationSec
        )
        return runCatching { SherpaOnnxVadInference(config) }.getOrNull()
    }
}
