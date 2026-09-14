package com.lingualive.audio

sealed class ModelInstallState {
    data object NotInstalled : ModelInstallState()
    data class Downloading(val downloadedBytes: Long, val totalBytes: Long) : ModelInstallState()
    data object Verifying : ModelInstallState()
    data object Installed : ModelInstallState()
    data class Failed(val reason: String) : ModelInstallState()
}
