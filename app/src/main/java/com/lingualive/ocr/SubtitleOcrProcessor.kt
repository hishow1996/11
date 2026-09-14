package com.lingualive.ocr

import com.lingualive.subtitle.SubtitleLine
import com.lingualive.subtitle.SubtitleRepository

class SubtitleOcrProcessor(
    private val engine: SubtitleOcrEngine,
    private val repository: SubtitleRepository
) {
    private var sequence = 0L
    private var lastText = ""

    suspend fun process(frame: OcrFrame, region: Rect? = null) {
        val results = engine.recognize(frame, region)
        val text = results.asSequence()
            .map { it.text.trim() }
            .filter { it.isNotBlank() }
            .joinToString(" ")
            .replace(Regex("\\s+"), " ")
            .trim()

        if (text.isBlank() || normalize(text) == normalize(lastText)) return

        lastText = text
        repository.upsert(
            SubtitleLine(
                id = ++sequence,
                original = text,
                startTimeMs = frame.timestampMs,
                endTimeMs = frame.timestampMs + 2500L
            )
        )
    }

    fun release() {
        engine.release()
    }

    private fun normalize(value: String) =
        value.lowercase().replace(Regex("\\s+"), " ").trim()
}
