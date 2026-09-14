package com.lingualive.audio

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

class LocalAsrSession(private val modelRoot: File) {
    private var recognizer: SenseVoiceOfflineRecognizer? = null

    suspend fun start(): Boolean = withContext(Dispatchers.Default) {
        if (!SherpaNativeLoader.load()) return@withContext false
        val config = SenseVoiceConfigFactory.create(
            modelRoot,
            LocalAsrDeviceProfileProvider.current().recommendedThreads
        ) ?: return@withContext false
        val runtime = SenseVoiceRuntimeConfig(
            File(config.modelPath), File(config.tokensPath),
            config.language, config.useItn, config.numThreads
        )
        recognizer = runCatching { SenseVoiceOfflineRecognizer(runtime) }.getOrNull()
        recognizer != null
    }

    suspend fun transcribe(audio: OfflineAudioChunk): SenseVoiceResult? =
        withContext(Dispatchers.Default) { runCatching { recognizer?.transcribe(audio) }.getOrNull() }

    fun stop() { recognizer?.release(); recognizer = null }
}
