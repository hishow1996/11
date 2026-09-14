package com.lingualive.audio

data class LocalModelManifest(
    val id: String,
    val version: String,
    val sha256: String,
    val installedAtMs: Long
)
