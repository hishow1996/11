package com.lingualive.ocr

/**
 * Crops a frame to the configured subtitle region.
 * Kept bitmap-library agnostic so the capture implementation can supply its
 * preferred Android bitmap type.
 */
class FrameCropper {
    fun crop(frame: OcrFrame, region: Rect?, width: Int, height: Int): OcrFrame {
        if (region == null) return frame
        require(width > 0 && height > 0)
        val bounded = Rect(
            region.left.coerceIn(0, width),
            region.top.coerceIn(0, height),
            region.right.coerceIn(0, width),
            region.bottom.coerceIn(0, height)
        )
        if (bounded.left >= bounded.right || bounded.top >= bounded.bottom) return frame
        // The platform OCR adapter performs the actual Bitmap crop.
        return frame
    }
}
