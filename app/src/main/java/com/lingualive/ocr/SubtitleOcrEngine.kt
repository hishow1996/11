package com.lingualive.ocr

/**
 * OCR engine contract. A concrete Android ML Kit/Tesseract implementation can
 * consume Bitmap frames and return detected subtitle text with screen bounds.
 */
interface SubtitleOcrEngine {
    suspend fun recognize(
        frame: OcrFrame,
        region: Rect? = null
    ): List<OcrResult>

    fun release()
}

data class OcrFrame(
    val bitmap: Any,
    val timestampMs: Long
)
