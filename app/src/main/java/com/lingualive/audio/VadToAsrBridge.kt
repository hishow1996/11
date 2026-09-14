package com.lingualive.audio

class VadToAsrBridge(
    private val onChunk: suspend (OfflineAudioChunk) -> Unit
) {
    suspend fun submit(segment: VadAudioSegment) {
        if (segment.samples.isEmpty()) return
        onChunk(
            OfflineAudioChunk(
                segment.samples,
                16_000,
                segment.startSample * 1000L / 16_000L
            )
        )
    }
}
