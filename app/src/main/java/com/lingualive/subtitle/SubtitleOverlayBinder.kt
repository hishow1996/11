package com.lingualive.subtitle

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class SubtitleOverlayBinder(
    private val repository: SubtitleRepository,
    private val window: SubtitleOverlayWindow,
    private val scope: CoroutineScope
) {
    private var job: Job? = null

    fun bind() {
        job?.cancel()
        job = scope.launch {
            repository.lines.collectLatest { lines ->
                val line = lines.lastOrNull()
                if (line == null) {
                    window.hide()
                } else {
                    val text = listOf(line.original, line.translated)
                        .filter { it.isNotBlank() }
                        .joinToString("\n")
                    window.show(text)
                }
            }
        }
    }

    fun unbind() {
        job?.cancel()
        job = null
        window.hide()
    }
}
