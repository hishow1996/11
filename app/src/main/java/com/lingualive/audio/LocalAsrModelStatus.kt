package com.lingualive.audio

data class LocalAsrModelStatus(
    val installed: Boolean,
    val complete: Boolean,
    val valid: Boolean,
    val missingFiles: List<String> = emptyList(),
    val message: String = ""
)
