package com.lingualive.audio

/**
 * Stable local-ASR boundary. The concrete Sherpa-ONNX implementation is
 * loaded only when its native/model assets are available, so Android 9
 * installs are not made dependent on a native runtime.
 */
class LocalAsrPlaceholder : AsrEngine {
    override suspend fun transcribe(chunk: PcmChunk): String? = null
}
