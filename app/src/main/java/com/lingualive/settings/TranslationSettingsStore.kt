package com.lingualive.settings

import android.content.Context
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class TranslationSettingsStore(context: Context) {
    private val prefs = context.getSharedPreferences("lingualive_settings", Context.MODE_PRIVATE)
    private val _settings = MutableStateFlow(load())
    val settings: StateFlow<TranslationSettings> = _settings

    fun update(transform: (TranslationSettings) -> TranslationSettings) {
        val next = transform(_settings.value)
        _settings.value = next
        prefs.edit()
            .putString("source", next.sourceLanguage)
            .putString("target", next.targetLanguage)
            .putString("provider", next.providerId)
            .putBoolean("ocr", next.enableOcr)
            .putBoolean("audio", next.enableAudio)
            .putBoolean("original", next.showOriginal)
            .putFloat("font", next.overlayFontSizeSp)
            .putFloat("opacity", next.overlayOpacity)
            .apply()
    }

    private fun load() = TranslationSettings(
        sourceLanguage = prefs.getString("source", "auto") ?: "auto",
        targetLanguage = prefs.getString("target", "zh-CN") ?: "zh-CN",
        providerId = prefs.getString("provider", "auto") ?: "auto",
        enableOcr = prefs.getBoolean("ocr", true),
        enableAudio = prefs.getBoolean("audio", true),
        showOriginal = prefs.getBoolean("original", true),
        overlayFontSizeSp = prefs.getFloat("font", 20f),
        overlayOpacity = prefs.getFloat("opacity", 0.92f)
    )
}
