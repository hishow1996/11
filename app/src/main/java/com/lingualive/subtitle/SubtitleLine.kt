package com.lingualive.subtitle

data class SubtitleLine(
    val id: Long,
    val original: String,
    val translated: String = "",
    val startTimeMs: Long,
    val endTimeMs: Long,
    val source: SubtitleSource = SubtitleSource.SPEECH
)

enum class SubtitleSource {
    SPEECH,
    OCR,
    FILE
}
