package com.lingualive.translation

import java.util.ArrayDeque

class TranslationContextCache(private val maxItems: Int = 8) {
    private val items = ArrayDeque<Pair<String, String>>()

    @Synchronized
    fun add(source: String, target: String) {
        if (source.isBlank() || target.isBlank()) return
        items.addLast(source.trim() to target.trim())
        while (items.size > maxItems) items.removeFirst()
    }

    @Synchronized
    fun recentSource(maxChars: Int = 1200): String =
        items.joinToString("\n") { it.first }.takeLast(maxChars)

    @Synchronized
    fun clear() = items.clear()
}
