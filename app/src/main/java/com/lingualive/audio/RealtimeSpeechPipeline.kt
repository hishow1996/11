package com.lingualive.audio

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class RealtimeSpeechPipeline(
    private val scope: CoroutineScope,
    private val onUtterance: suspend (ShortArray) -> Unit
) {
    private val buffer = UtteranceBuffer()

    fun offer(samples: ShortArray, speechDetected: Boolean) {
        if (samples.isEmpty()) return
        buffer.append(samples)
        if (!speechDetected && buffer.size() >= 2400) {
            val utterance = buffer.take()
            scope.launch(Dispatchers.Default) {
                onUtterance(utterance)
            }
        }
    }

    fun flush() {
        val utterance = buffer.take()
        if (utterance.isNotEmpty()) scope.launch { onUtterance(utterance) }
    }
}
