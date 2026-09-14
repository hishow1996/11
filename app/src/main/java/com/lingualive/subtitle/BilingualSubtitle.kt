package com.lingualive.subtitle

data class SubtitleBox(
    val original: String,
    val translated: String = "",
    val left: Int = 0,
    val top: Int = 0,
    val right: Int = 0,
    val bottom: Int = 0,
    val timestampMs: Long = System.currentTimeMillis()
)

data class SubtitleSettings(
    val enabled: Boolean = true,
    val fontSizeSp: Float = 18f,
    val opacity: Float = 0.88f,
    val bottomMarginDp: Int = 72,
    val showOriginal: Boolean = true
)
