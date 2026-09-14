package com.lingualive.ui

data class SettingsUiState(
    val sourceLanguage: String = "auto",
    val targetLanguage: String = "zh-CN",
    val engine: String = "auto",
    val showOriginal: Boolean = true,
    val fontSizeSp: Float = 22f,
    val backgroundAlpha: Float = 0.72f
)
