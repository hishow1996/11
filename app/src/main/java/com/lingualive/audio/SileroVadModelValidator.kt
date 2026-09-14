package com.lingualive.audio

import java.io.File

object SileroVadModelValidator {
    fun validate(config: SileroVadModelConfig): Boolean {
        val file = File(config.modelPath)
        return file.isFile && file.length() > 0 && config.sampleRate > 0 && config.windowSamples > 0
    }
}