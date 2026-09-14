package com.lingualive.subtitle

data class SubtitleStyle(
    val fontSizeSp: Float = 22f,
    val backgroundAlpha: Float = 0.72f,
    val cornerRadiusDp: Float = 12f,
    val showOriginal: Boolean = true,
    val showTranslation: Boolean = true
)
