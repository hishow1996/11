package com.lingualive.subtitle

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

class SubtitleRepository {
    private val _lines = MutableStateFlow<List<SubtitleLine>>(emptyList())
    val lines: Flow<List<SubtitleLine>> = _lines.asStateFlow()

    fun upsert(line: SubtitleLine) {
        _lines.value = (_lines.value.filterNot { it.id == line.id } + line)
            .sortedBy { it.startTimeMs }
            .takeLast(200)
    }

    fun clear() {
        _lines.value = emptyList()
    }
}
