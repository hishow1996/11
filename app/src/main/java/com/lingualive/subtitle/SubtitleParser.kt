package com.lingualive.subtitle

object SubtitleParser {
    fun parse(content: String, format: SubtitleFormat): List<SubtitleLine> = when (format) {
        SubtitleFormat.SRT -> parseSrt(content)
        SubtitleFormat.VTT -> parseVtt(content)
    }

    private fun parseSrt(content: String): List<SubtitleLine> {
        val blocks = content.replace("\r", "").trim().split(Regex("""\n\s*\n"""))
        return blocks.mapIndexedNotNull { index, block ->
            val lines = block.lines().filter { it.isNotBlank() }
            val timeIndex = lines.indexOfFirst { it.contains("-->") }
            if (timeIndex < 0) return@mapIndexedNotNull null
            val times = lines[timeIndex].split("-->")
            if (times.size != 2) return@mapIndexedNotNull null
            val text = lines.drop(timeIndex + 1).joinToString("\n").trim()
            if (text.isBlank()) return@mapIndexedNotNull null
            SubtitleLine(
                id = index.toLong(),
                original = text,
                startTimeMs = parseTime(times[0]),
                endTimeMs = parseTime(times[1])
            )
        }
    }

    private fun parseVtt(content: String): List<SubtitleLine> {
        val lines = content.replace("\r", "").lines()
        val start = lines.indexOfFirst { it.trim().equals("WEBVTT", ignoreCase = true) }
        val body = if (start >= 0) lines.drop(start + 1).joinToString("\n") else content
        return parseSrt(body)
    }

    private fun parseTime(value: String): Long {
        val clean = value.trim().substringBefore(" ")
        val parts = clean.replace(',', '.').split(":")
        return when (parts.size) {
            3 -> parts[0].toLongOrNull().orZero() * 3_600_000L +
                parts[1].toLongOrNull().orZero() * 60_000L + parseSeconds(parts[2])
            2 -> parts[0].toLongOrNull().orZero() * 60_000L + parseSeconds(parts[1])
            else -> 0L
        }
    }

    private fun parseSeconds(value: String): Long {
        val whole = value.substringBefore('.').toLongOrNull() ?: 0L
        val millis = value.substringAfter('.', "").padEnd(3, '0').take(3).toLongOrNull() ?: 0L
        return whole * 1000L + millis
    }

    private fun Long?.orZero(): Long = this ?: 0L
}

enum class SubtitleFormat { SRT, VTT }
