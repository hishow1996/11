package com.lingualive.ui

data class LiveTranslateUiState(
    val running: Boolean = false,
    val sourceLanguage: String = "auto",
    val targetLanguage: String = "zh-CN",
    val showOriginal: Boolean = true,
    val showTranslation: Boolean = true,
    val fontSizeSp: Float = 22f,
    val backgroundAlpha: Float = 0.72f
)
