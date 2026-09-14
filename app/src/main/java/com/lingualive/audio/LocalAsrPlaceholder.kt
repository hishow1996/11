package com.lingualive.audio

/**
 * Safe local-ASR boundary. The Sherpa-ONNX implementation can be supplied
 * when its native library and model files are present.
 */
class LocalAsrPlaceholder : AsrEngine {
    override val id: String = "local-placeholder"
    override suspend fun transcribe(audio: ShortArray, sampleRate: Int): AsrResult? = null
}
