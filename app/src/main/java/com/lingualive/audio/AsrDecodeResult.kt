package com.lingualive.audio

data class AsrDecodeResult(val requestId: Long, val result: SenseVoiceResult?, val state: AsrDecodeState, val latencyMs: Long)
