package com.lingualive.translate

class TranslationCache(private val maxEntries: Int = 256) {
    private val cache = object : LinkedHashMap<String, TranslationResult>(maxEntries, 0.75f, true) {
        override fun removeEldestEntry(
            eldest: MutableMap.MutableEntry<String, TranslationResult>
        ): Boolean = size > maxEntries
    }

    @Synchronized
    fun get(text: String, source: String, target: String): TranslationResult? =
        cache[key(text, source, target)]?.copy(cached = true)

    @Synchronized
    fun put(text: String, source: String, target: String, result: TranslationResult) {
        cache[key(text, source, target)] = result
    }

    @Synchronized
    fun clear() = cache.clear()

    private fun key(text: String, source: String, target: String): String =
        source + "\u0000" + target + "\u0000" + text.trim()
}
