package com.lingualive.audio

object SenseVoiceConfigFactory {
    fun create(root: java.io.File, threads: Int): SenseVoiceModelConfig? {
        val files = LocalAsrAvailability.find(root) ?: return null
        return SenseVoiceModelConfig(
            modelPath = files.model.absolutePath,
            tokensPath = files.tokens.absolutePath,
            vadPath = files.vad.absolutePath,
            language = "auto",
            useItn = true,
            sampleRate = 16_000,
            numThreads = threads.coerceIn(1, 4)
        )
    }
}
