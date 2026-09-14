package com.lingualive.ocr

data class OcrResult(
    val text: String,
    val confidence: Float = 0f,
    val timestampMs: Long,
    val bounds: Rect? = null
)

data class Rect(
    val left: Int,
    val top: Int,
    val right: Int,
    val bottom: Int
)
