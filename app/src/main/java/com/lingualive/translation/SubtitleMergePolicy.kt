package com.lingualive.translation

/** Prevents rapid replacement of a subtitle with nearly identical text. */
class SubtitleMergePolicy(private val minCharsDelta: Int = 2) {
    private var last = ""
    fun accept(text: String): Boolean {
        val value = text.trim()
        if (value.isEmpty() || value == last) return false
        if (last.isNotEmpty() && kotlin.math.abs(value.length - last.length) < minCharsDelta &&
            (value.contains(last) || last.contains(value))) return false
        last = value
        return true
    }
    fun clear() { last = "" }
}
