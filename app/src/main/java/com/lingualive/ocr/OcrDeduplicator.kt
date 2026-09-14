package com.lingualive.ocr

class OcrDeduplicator(private val minChangeChars: Int = 2) {
    private var previous = ""

    fun accept(text: String): Boolean {
        val normalized = OcrTextNormalizer.normalize(text)
        if (!OcrTextNormalizer.isUseful(normalized)) return false
        if (normalized == previous) return false
        val distance = levenshtein(previous, normalized)
        if (previous.isNotEmpty() && distance < minChangeChars) return false
        previous = normalized
        return true
    }

    private fun levenshtein(a: String, b: String): Int {
        if (a.isEmpty()) return b.length
        if (b.isEmpty()) return a.length
        var prev = IntArray(b.length + 1) { it }
        for (i in a.indices) {
            val cur = IntArray(b.length + 1)
            cur[0] = i + 1
            for (j in b.indices) {
                cur[j + 1] = minOf(
                    cur[j] + 1,
                    prev[j + 1] + 1,
                    prev[j] + if (a[i] == b[j]) 0 else 1
                )
            }
            prev = cur
        }
        return prev[b.length]
    }
}
