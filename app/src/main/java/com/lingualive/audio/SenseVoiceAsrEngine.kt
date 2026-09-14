package com.lingualive.audio

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

/**
 * Adapter boundary for the official sherpa-onnx SenseVoice runtime.
 * It validates the external model set before native initialization.
 */
class SenseVoiceAsrEngine(
    private val modelRoot: File,
    private val config: SenseVoiceModelConfig
) : AsrEngine {
    override val id: String = "sensevoice-local"

    override suspend fun transcribe(audio: ShortArray, sampleRate: Int): AsrResult? =
        withContext(Dispatchers.Default) {
            if (!SherpaOnnxRuntimeGuard.isAvailable()) return@withContext null
            if (sampleRate != config.sampleRate || audio.isEmpty()) return@withContext null
            val files = LocalAsrAvailability.find(modelRoot) ?: return@withContext null

            // Native recognizer construction is intentionally isolated here.
            // This keeps model-path validation independent from Android 9 startup.
            runCatching {
                val recognizerClass = Class.forName("com.k2fsa.sherpa.onnx.OfflineRecognizer")
                require(files.model.isFile && files.tokens.isFile)
                // Actual JNI binding is added after the exact AAR API is pinned.
                recognizerClass.name
                null
            }.getOrNull()
        }
}
