package com.lingualive.subtitle

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class SubtitleOverlayState {
    private val _visible = MutableStateFlow(false)
    val visible: StateFlow<Boolean> = _visible.asStateFlow()

    private val _style = MutableStateFlow(SubtitleStyle())
    val style: StateFlow<SubtitleStyle> = _style.asStateFlow()

    fun show() { _visible.value = true }
    fun hide() { _visible.value = false }

    fun updateStyle(style: SubtitleStyle) {
        _style.value = style.copy(
            fontSizeSp = style.fontSizeSp.coerceIn(12f, 64f),
            backgroundAlpha = style.backgroundAlpha.coerceIn(0f, 1f),
            cornerRadiusDp = style.cornerRadiusDp.coerceIn(0f, 32f)
        )
    }
}
