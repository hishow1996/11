package com.lingualive.audio

data class AsrSelection(
    val engineId: String?,
    val localReady: Boolean,
    val online: Boolean,
    val reason: String
)
