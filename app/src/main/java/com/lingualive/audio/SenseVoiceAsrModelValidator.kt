package com.lingualive.audio

import java.io.File

object SenseVoiceAsrModelValidator {
    fun validate(config: SenseVoiceAsrConfig): Boolean {
        val model = File(config.modelPath)
        val tokens = File(config.tokensPath)
        return model.isFile && model.length() > 0L && tokens.isFile && tokens.length() > 0L && config.sampleRate == 16_000 && config.numThreads > 0
    }
}
