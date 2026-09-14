package com.lingualive.settings

data class TranslationSettings(
    val sourceLanguage: String = "auto",
    val targetLanguage: String = "zh-CN",
    val providerId: String = "auto",
    val enableOcr: Boolean = true,
    val enableAudio: Boolean = true,
    val showOriginal: Boolean = true,
    val overlayFontSizeSp: Float = 20f,
    val overlayOpacity: Float = 0.92f
)
