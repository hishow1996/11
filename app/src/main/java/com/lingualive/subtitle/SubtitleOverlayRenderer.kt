package com.lingualive.subtitle

class SubtitleOverlayRenderer {
    fun render(line: SubtitleLine, style: SubtitleStyle): String {
        val original = if (style.showOriginal) line.original.trim() else ""
        val translation = if (style.showTranslation) line.translated.trim() else ""
        return listOf(original, translation)
            .filter { it.isNotBlank() }
            .joinToString("\n")
    }
}
