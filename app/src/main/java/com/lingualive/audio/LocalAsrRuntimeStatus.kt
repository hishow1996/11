package com.lingualive.audio

data class LocalAsrRuntimeStatus(
    val runtimeAvailable: Boolean,
    val modelComplete: Boolean,
    val ready: Boolean,
    val reason: String
)
