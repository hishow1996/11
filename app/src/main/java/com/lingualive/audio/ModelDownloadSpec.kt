package com.lingualive.audio

data class ModelDownloadSpec(
    val id: String,
    val version: String,
    val archiveUrl: String,
    val sha256: String,
    val sizeBytes: Long
)
