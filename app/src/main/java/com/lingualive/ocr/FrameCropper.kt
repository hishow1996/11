package com.lingualive.ocr

import android.graphics.Bitmap

/**
 * Crops a frame to the configured subtitle region.
 * The returned frame owns the cropped bitmap; the input frame remains owned by
 * the caller and is never recycled here.
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

        val bitmap = frame.bitmap as? Bitmap ?: return frame
        val crop = Bitmap.createBitmap(
            bitmap,
            bounded.left,
            bounded.top,
            bounded.right - bounded.left,
            bounded.bottom - bounded.top
        )
        return OcrFrame(crop, frame.timestampMs)
    }
}
