package com.lingualive.subtitle

class SubtitleOverlayDragController(
    private var layout: SubtitleOverlayLayout = SubtitleOverlayLayout()
) {
    fun move(dxDp: Float, dyDp: Float): SubtitleOverlayLayout {
        layout = layout.movedBy(dxDp, dyDp)
        return layout
    }

    fun current(): SubtitleOverlayLayout = layout
}
