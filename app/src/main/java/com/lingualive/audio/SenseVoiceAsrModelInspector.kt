package com.lingualive.audio

import java.io.File

object SenseVoiceAsrModelInspector {
    fun inspect(config: SenseVoiceAsrConfig): SenseVoiceAsrModelStatus {
        val model = File(config.modelPath)
        val tokens = File(config.tokensPath)
        if (!model.exists() || !tokens.exists()) return SenseVoiceAsrModelStatus.MISSING
        return if (SenseVoiceAsrModelValidator.validate(config)) SenseVoiceAsrModelStatus.READY else SenseVoiceAsrModelStatus.INVALID
    }
}
