package com.lingualive.subtitle

class SubtitleOverlayController(
    private val state: SubtitleOverlayState = SubtitleOverlayStateHolder.state
) {
    fun show() = state.show()
    fun hide() = state.hide()
    fun setStyle(style: SubtitleStyle) = state.updateStyle(style)
}
