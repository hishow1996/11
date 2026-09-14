package com.lingualive.audio

import kotlin.system.measureTimeMillis

class AsrInferenceRunner(private val session: LocalAsrSession) {
    suspend fun run(request: AsrDecodeRequest): AsrDecodeResult {
        if (!request.audio.valid()) return AsrDecodeResult(request.requestId, null, AsrDecodeState.FAILED, 0)
        var result: SenseVoiceResult? = null
        val elapsed = measureTimeMillis { result = session.transcribe(request.audio) }
        val state = if (result == null) AsrDecodeState.EMPTY else AsrDecodeState.COMPLETED
        return AsrDecodeResult(request.requestId, result, state, elapsed)
    }
}
