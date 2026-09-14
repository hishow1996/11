package com.lingualive.translation

class SubtitleDeduplicator {
    private var last = ""
    fun accept(text: String): Boolean {
        val value = text.trim()
        if (value.isEmpty() || value == last) return false
        last = value
        return true
    }
    fun reset() { last = "" }
}
