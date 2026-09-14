package com.lingualive.translation

import java.util.LinkedHashMap

class TranslationMemory(private val maxEntries: Int = 200) {
    private val cache = object : LinkedHashMap<String, String>(maxEntries, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, String>?) = size > maxEntries
    }

    @Synchronized fun get(source: String, target: String, text: String): String? = cache[key(source, target, text)]

    @Synchronized fun put(source: String, target: String, text: String, translated: String) {
        if (text.isNotBlank() && translated.isNotBlank()) cache[key(source, target, text)] = translated
    }

    @Synchronized fun clear() = cache.clear()

    private fun key(source: String, target: String, text: String) = "$source|$target|${text.trim()}"
}
