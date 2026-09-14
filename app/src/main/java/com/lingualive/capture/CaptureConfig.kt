package com.lingualive.capture

import com.lingualive.ocr.SubtitleRegion

data class CaptureConfig(
    val width: Int,
    val height: Int,
    val dpi: Int,
    val maxFps: Int = 15,
    val ocrIntervalMs: Long = 700L,
    val subtitleRegion: SubtitleRegion = SubtitleRegion()
)
