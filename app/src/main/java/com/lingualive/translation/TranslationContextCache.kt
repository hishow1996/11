package com.lingualive.translation

import java.util.ArrayDeque

/** Small bounded context window for more coherent consecutive subtitle translations. */
class TranslationContextCache(private val maxItems: Int = 8) {
    private val items = ArrayDeque<Pair<String,String>>()
    @Synchronized fun add(source: String, target: String) {
        if (source.isBlank() || target.isBlank()) return
        items.addLast(source.trim() to target.trim())
        while (items.size > maxItems) items.removeFirst()
    }
    @Synchronized fun recentSource(maxChars: Int = 1200): String =
        items.map { it.first }.joinToString("
").takeLast(maxChars)
    @Synchronized fun clear() = items.clear()
}
