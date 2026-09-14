package com.lingualive.audio

sealed class AudioCaptureState {
    data object Idle : AudioCaptureState()
    data object Preparing : AudioCaptureState()
    data object Capturing : AudioCaptureState()
    data class Error(val message: String) : AudioCaptureState()
}
