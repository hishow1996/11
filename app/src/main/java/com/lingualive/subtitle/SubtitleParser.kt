package com.lingualive.subtitle

object SubtitleParser {
    fun parse(content: String, format: SubtitleFormat): List<SubtitleLine> {
        return when (format) {
            SubtitleFormat.SRT -> parseSrt(content)
            SubtitleFormat.VTT -> parseVtt(content)
        }
    }

    private fun parseSrt(content: String): List<SubtitleLine> {
        val blocks = content.replace("\r", "").trim().split(Regex("\n\s*\n"))
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
        val body = content.replace("\r", "")
            .lines()
            .dropWhile { it.trim() != "" }
            .drop(1)
            .joinToString("\n")
        return parseSrt(body)
    }

    private fun parseTime(value: String): Long {
        val clean = value.trim().substringBefore(" ")
        val p = clean.replace(',', '.').split(":")
        return when (p.size) {
            3 -> (p[0].toLong() * 3600000) +
                (p[1].toLong() * 60000) +
                (p[2].substringBefore('.').toLong() * 1000) +
                p[2].substringAfter('.', "0").padEnd(3, '0').take(3).toLong()
            2 -> (p[0].toLong() * 60000) +
                (p[1].substringBefore('.').toLong() * 1000) +
                p[1].substringAfter('.', "0").padEnd(3, '0').take(3).toLong()
            else -> 0L
        }
    }
}

enum class SubtitleFormat { SRT, VTT }
