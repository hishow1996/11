package com.lingualive.subtitle

class SubtitleManager {

    private val subtitles = mutableListOf<String>()

    fun add(text: String) {
        subtitles.add(text)
    }

    fun latest(): String? = subtitles.lastOrNull()
}
