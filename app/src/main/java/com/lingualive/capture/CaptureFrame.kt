package com.lingualive.capture

data class CaptureFrame(
    val bitmap: Any,
    val width: Int,
    val height: Int,
    val timestampMs: Long
)
