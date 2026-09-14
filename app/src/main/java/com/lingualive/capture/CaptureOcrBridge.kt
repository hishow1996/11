package com.lingualive.capture

import android.graphics.Bitmap
import com.lingualive.ocr.LiveOcrPipeline
import com.lingualive.ocr.SubtitleRegion
import kotlinx.coroutines.flow.StateFlow
import com.lingualive.ocr.OcrResult

class CaptureOcrBridge(
    private val config: CaptureConfig,
    private val pipeline: LiveOcrPipeline = LiveOcrPipeline()
) {
    val latest: StateFlow<OcrResult?> = pipeline.latest
    private var lastSubmittedAt = 0L

    fun onFrame(bitmap: Bitmap) {
        val now = android.os.SystemClock.elapsedRealtime()
        if (now - lastSubmittedAt < config.ocrIntervalMs) return
        lastSubmittedAt = now

        val region = config.subtitleRegion.toPixels(bitmap.width, bitmap.height)
        val left = region.left.coerceIn(0, bitmap.width - 1)
        val top = region.top.coerceIn(0, bitmap.height - 1)
        val right = region.right.coerceIn(left + 1, bitmap.width)
        val bottom = region.bottom.coerceIn(top + 1, bitmap.height)
        val crop = Bitmap.createBitmap(bitmap, left, top, right - left, bottom - top)
        pipeline.submit(crop)
        crop.recycle()
    }

    fun close() = pipeline.close()
}
