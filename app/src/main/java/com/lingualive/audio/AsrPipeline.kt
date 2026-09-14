package com.lingualive.audio

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class AsrPipeline(private val engine: AsrEngine) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val _latest = MutableStateFlow<AsrResult?>(null)
    val latest: StateFlow<AsrResult?> = _latest
    private var job: Job? = null

    fun submit(chunk: PcmChunk) {
        if (chunk.samples.isEmpty()) return
        job?.cancel()
        job = scope.launch {
            engine.transcribe(chunk.samples, chunk.sampleRate)?.let { _latest.value = it }
        }
    }

    fun close() { job?.cancel(); scope.coroutineContext[Job]?.cancel() }
}
