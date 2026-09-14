package com.lingualive.subtitle

data class OverlayPosition(
    val xDp: Float = 0f,
    val yDp: Float = 0f
)

data class SubtitleOverlayLayout(
    val position: OverlayPosition = OverlayPosition(),
    val maxWidthDp: Float = 360f,
    val paddingDp: Float = 12f
) {
    fun movedBy(dx: Float, dy: Float): SubtitleOverlayLayout =
        copy(position = OverlayPosition(position.xDp + dx, position.yDp + dy))
}
