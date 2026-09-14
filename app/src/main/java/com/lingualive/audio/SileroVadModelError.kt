package com.lingualive.audio

sealed class SileroVadModelError {
    data object Missing : SileroVadModelError()
    data object Invalid : SileroVadModelError()
    data class LoadFailed(val message: String) : SileroVadModelError()
}
