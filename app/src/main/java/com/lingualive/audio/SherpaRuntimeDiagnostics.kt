package com.lingualive.audio

data class SherpaRuntimeDiagnostics(
    val classPresent: Boolean,
    val nativeLoaded: Boolean,
    val abi: String,
    val sdk: Int
)
