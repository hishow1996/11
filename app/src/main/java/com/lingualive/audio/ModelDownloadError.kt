package com.lingualive.audio

enum class ModelDownloadError {
    NETWORK,
    HTTP,
    DISK_SPACE,
    CHECKSUM,
    INCOMPLETE,
    CANCELLED
}
