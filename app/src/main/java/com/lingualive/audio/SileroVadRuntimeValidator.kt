package com.lingualive.audio

import java.io.File

object SileroVadRuntimeValidator {
    fun validate(config: SileroVadRuntimeConfig): Boolean {
        return config.sampleRate == 16_000 &&
            config.windowSize > 0 &&
            config.threshold in 0f..1f &&
            config.minSpeechSeconds >= 0f &&
            config.minSilenceSeconds >= 0f &&
            config.maxSpeechSeconds > 0f &&
            config.numThreads > 0 &&
            File(config.modelPath).isFile && File(config.modelPath).length() > 0
    }
}
