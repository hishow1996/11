package com.lingualive.audio

data class SherpaOnnxRuntimeStatus(
    val jniAvailable: Boolean,
    val modelAvailable: Boolean,
    val ready: Boolean
)
