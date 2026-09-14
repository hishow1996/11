package com.lingualive.audio

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

/** Buffers playback-capture chunks into bounded ASR windows and flushes short utterances on VAD endpoint. */
class AsrPipeline(
    private val engine: AsrEngine,
    private val vad: VoiceActivityDetector = VoiceActivityDetector(),
    private val windowMs: Long = 3_000,
    private val minUtteranceMs: Long = 800
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
        val hasVoice = vad.hasVoice(chunk.samples, sampleRate)

        if (hasVoice) {
            append(chunk.samples)
            val targetSamples = (sampleRate * windowMs / 1000L).toInt()
            if (bufferedSamples >= targetSamples) transcribe(targetSamples)
        } else if (bufferedSamples >= (sampleRate * minUtteranceMs / 1000L).toInt()) {
            transcribe(bufferedSamples)
        }
    }

    private fun transcribe(sampleCount: Int) {
        if (sampleCount <= 0 || job?.isActive == true) return
        val audio = buffered.copyOf(sampleCount.coerceAtMost(bufferedSamples))
        val remainingCount = bufferedSamples - audio.size
        val remaining = if (remainingCount > 0) {
            buffered.copyOfRange(audio.size, bufferedSamples)
        } else {
            ShortArray(0)
        }
        buffered = remaining
        bufferedSamples = remaining.size
        val rate = sampleRate

        job = scope.launch {
            runCatching { engine.transcribe(audio, rate) }
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
