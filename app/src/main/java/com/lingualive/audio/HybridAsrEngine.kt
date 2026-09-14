package com.lingualive.audio

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/** Uses a local engine when available, then falls back to cloud ASR. */
class HybridAsrEngine(
    private val local: AsrEngine?,
    private val cloud: AsrEngine?
) : AsrEngine {
    override val id = "hybrid"

    override suspend fun transcribe(audio: ShortArray, sampleRate: Int): AsrResult? = withContext(Dispatchers.Default) {
        if (audio.isEmpty()) return@withContext null
        local?.let { engine ->
            runCatching { engine.transcribe(audio, sampleRate) }.getOrNull()?.let { return@withContext it }
        }
        cloud?.let { engine ->
            runCatching { engine.transcribe(audio, sampleRate) }.getOrNull()?.let { return@withContext it }
        }
        null
    }
}
