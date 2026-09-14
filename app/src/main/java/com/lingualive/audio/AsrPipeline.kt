package com.lingualive.audio

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class AsrPipeline(private val engine: AsrEngine, private val vad: VoiceActivityDetector = VoiceActivityDetector()) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val _latest = MutableStateFlow<AsrResult?>(null)
    val latest: StateFlow<AsrResult?> = _latest
    private var job: Job? = null

    fun submit(chunk: PcmChunk) {
        if (chunk.samples.isEmpty() || !vad.hasVoice(chunk.samples)) return
        val samples = chunk.samples.copyOf()
        job?.cancel()
        job = scope.launch {
            engine.transcribe(samples, chunk.sampleRate)?.let { result ->
                if (result.text.isNotBlank()) _latest.value = result
            }
        }
    }

    fun close() { job?.cancel(); vad.reset(); scope.coroutineContext[Job]?.cancel() }
}
