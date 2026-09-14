package com.lingualive.subtitle

class SubtitleMerger {
    fun merge(
        original: SubtitleLine,
        translated: String
    ): SubtitleLine = original.copy(translated = translated.trim())

    fun isDuplicate(previous: SubtitleLine?, currentText: String): Boolean {
        if (previous == null) return false
        return normalize(previous.original) == normalize(currentText)
    }

    private fun normalize(value: String): String =
        value.lowercase().replace(Regex("\\s+"), " ").trim()
}
