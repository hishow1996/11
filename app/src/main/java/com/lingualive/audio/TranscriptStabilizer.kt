package com.lingualive.audio

class TranscriptStabilizer(private val maxRecent: Int = 12) {
    private val recent = ArrayDeque<String>()

    @Synchronized
    fun accept(text: String): String? {
        val normalized = text.trim().replace("  ", " ")
        if (normalized.isBlank()) return null
        val key = normalized.lowercase()
        if (recent.contains(key)) return null
        recent.addLast(key)
        while (recent.size > maxRecent) recent.removeFirst()
        return normalized
    }

    @Synchronized
    fun clear() = recent.clear()
}
