package com.lingualive.audio

data class ModelDownloadProgress(
    val downloadedBytes: Long,
    val totalBytes: Long,
    val percent: Int
)
