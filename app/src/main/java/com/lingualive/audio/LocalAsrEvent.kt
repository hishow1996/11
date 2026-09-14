package com.lingualive.audio

sealed class LocalAsrEvent {
    data object Starting : LocalAsrEvent()
    data object Ready : LocalAsrEvent()
    data class Partial(val text: String) : LocalAsrEvent()
    data class Final(val text: String, val timestamp: SpeechChunkTimestamp) : LocalAsrEvent()
    data class Error(val reason: LocalAsrFailure) : LocalAsrEvent()
}
