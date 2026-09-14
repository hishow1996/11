package com.lingualive.ocr

import com.lingualive.subtitle.SubtitleRepository

class LiveOcrController(
    private val engine: SubtitleOcrEngine,
    private val repository: SubtitleRepository
) {
    private val processor = SubtitleOcrProcessor(engine, repository)

    suspend fun submit(frame: OcrFrame, region: SubtitleRegion? = null, width: Int = 1, height: Int = 1) {
        val pixelRegion = region?.toPixels(width, height)
        processor.process(frame, pixelRegion)
    }

    fun release() {
        processor.release()
    }
}
