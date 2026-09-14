package com.lingualive.ocr

import com.lingualive.subtitle.SubtitleLine
import com.lingualive.subtitle.SubtitleRepository
import com.lingualive.translate.TranslationHub

class SubtitleTranslationPipeline(
    private val hub: TranslationHub,
    private val repository: SubtitleRepository
) {
    suspend fun translate(line: SubtitleLine, source: String = "auto", target: String = "zh-CN") {
        if (line.original.isBlank()) return
        val result = hub.translate(line.original, source, target)
        repository.upsert(line.copy(translated = result.translated))
    }
}
