package com.lingualive.capture

import android.graphics.Bitmap
import com.lingualive.ocr.LiveOcrPipeline
import kotlinx.coroutines.flow.StateFlow
import com.lingualive.ocr.OcrResult

class CaptureOcrBridge(
    private val pipeline: LiveOcrPipeline = LiveOcrPipeline()
) {
    val latest: StateFlow<OcrResult?> = pipeline.latest

    fun onFrame(bitmap: Bitmap) = pipeline.submit(bitmap)

    fun close() = pipeline.close()
}
