package com.lingualive.audio

object SenseVoiceRuntimeValidator {
    fun validate(config: SenseVoiceRuntimeConfig): Boolean =
        SherpaNativeLoader.load() && config.valid()
}
