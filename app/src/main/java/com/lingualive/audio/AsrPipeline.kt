package com.lingualive.audio

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

/** Buffers short playback-capture chunks into usable ASR windows instead of cancelling every request. */
class AsrPipeline(
    private val engine: AsrEngine,
    private val vad: VoiceActivityDetector = VoiceActivityDetector(),
    private val windowMs: Long = 3_000
) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val _latest = MutableStateFlow<AsrResult?>(null)
    val latest: StateFlow<AsrResult?> = _latest
    private var job: Job? = null
    private var sampleRate = 16_000
    private var buffered = ShortArray(0)
    private var bufferedSamples = 0

    fun submit(chunk: PcmChunk) {
        if (chunk.samples.isEmpty()) return
        sampleRate = chunk.sampleRate
        if (!vad.hasVoice(chunk.samples)) return

        append(chunk.samples)
        val targetSamples = (sampleRate * windowMs / 1000L).toInt()
        if (bufferedSamples < targetSamples || job?.isActive == true) return

        val audio = buffered.copyOf(targetSamples)
        val remaining = buffered.copyOfRange(targetSamples, bufferedSamples)
        buffered = remaining
        bufferedSamples = remaining.size

        job = scope.launch {
            runCatching { engine.transcribe(audio, sampleRate) }
                .getOrNull()
                ?.takeIf { it.text.isNotBlank() }
                ?.let { _latest.value = it }
        }
    }

    private fun append(samples: ShortArray) {
        val required = bufferedSamples + samples.size
        if (required > buffered.size) {
            var capacity = maxOf(4_800, buffered.size * 2)
            while (capacity < required) capacity *= 2
            buffered = buffered.copyOf(capacity)
        }
        samples.copyInto(buffered, destinationOffset = bufferedSamples)
        bufferedSamples = required
    }

    fun close() {
        job?.cancel()
        job = null
        buffered = ShortArray(0)
        bufferedSamples = 0
        vad.reset()
        scope.coroutineContext[Job]?.cancel()
    }
}
