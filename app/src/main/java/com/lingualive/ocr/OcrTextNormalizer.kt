package com.lingualive.ocr

object OcrTextNormalizer {
    fun normalize(value: String): String =
        value.replace(Regex("\\s+"), " ").trim()

    fun isUseful(value: String): Boolean {
        val text = normalize(value)
        return text.length >= 2 && text.any { it.isLetterOrDigit() }
    }
}
