package com.lingualive.ui

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class LiveTranslateViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(LiveTranslateUiState())
    val uiState: StateFlow<LiveTranslateUiState> = _uiState.asStateFlow()

    fun start() {
        _uiState.value = _uiState.value.copy(running = true)
    }

    fun stop() {
        _uiState.value = _uiState.value.copy(running = false)
    }

    fun setLanguages(source: String, target: String) {
        _uiState.value = _uiState.value.copy(
            sourceLanguage = source,
            targetLanguage = target
        )
    }

    fun setSubtitleOptions(showOriginal: Boolean, showTranslation: Boolean) {
        _uiState.value = _uiState.value.copy(
            showOriginal = showOriginal,
            showTranslation = showTranslation
        )
    }

    fun setFontSize(value: Float) {
        _uiState.value = _uiState.value.copy(fontSizeSp = value.coerceIn(12f, 64f))
    }

    fun setBackgroundAlpha(value: Float) {
        _uiState.value = _uiState.value.copy(backgroundAlpha = value.coerceIn(0f, 1f))
    }
}
