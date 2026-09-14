package com.lingualive.audio

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

/** Low-latency utterance buffer with pre-roll, endpoint flush and bounded memory. */
class AsrPipeline(
    private val engine: AsrEngine,
    private val vad: VoiceActivityDetector = VoiceActivityDetector(),
    private val windowMs: Long = 2_800,
    private val minUtteranceMs: Long = 550,
    private val maxUtteranceMs: Long = 8_000,
    private val preRollMs: Long = 300
) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val _latest = MutableStateFlow<AsrResult?>(null)
    val latest: StateFlow<AsrResult?> = _latest
    private var job: Job? = null
    private var sampleRate = 16_000
    private var buffered = ShortArray(0)
    private var bufferedSamples = 0
    private var pendingFlushSamples = 0
    private var silenceSamples = 0
    private var preRoll = ShortArray(0)

    fun submit(chunk: PcmChunk) {
        if (chunk.samples.isEmpty()) return
        sampleRate = chunk.sampleRate
        val preRollSamples = (sampleRate * preRollMs / 1000L).toInt()
        val maxSamples = (sampleRate * maxUtteranceMs / 1000L).toInt()
        val minSamples = (sampleRate * minUtteranceMs / 1000L).toInt()
        val targetSamples = (sampleRate * windowMs / 1000L).toInt()
        val hasVoice = vad.hasVoice(chunk.samples, sampleRate)

        if (hasVoice) {
            if (bufferedSamples == 0 && preRoll.isNotEmpty()) append(preRoll)
            append(chunk.samples)
            silenceSamples = 0
            if (bufferedSamples >= targetSamples || bufferedSamples >= maxSamples) requestTranscription(minOf(bufferedSamples, maxSamples))
        } else {
            silenceSamples += chunk.samples.size
            updatePreRoll(chunk.samples, preRollSamples)
            if (bufferedSamples >= minSamples && silenceSamples >= sampleRate * 550 / 1000) requestTranscription(bufferedSamples)
        }
    }

    private fun requestTranscription(sampleCount: Int) {
        val requested = sampleCount.coerceAtMost(bufferedSamples)
        if (requested <= 0) return
        if (job?.isActive == true) {
            pendingFlushSamples = maxOf(pendingFlushSamples, requested)
            return
        }
        transcribe(requested)
    }

    private fun transcribe(sampleCount: Int) {
        val actualCount = sampleCount.coerceAtMost(bufferedSamples)
        if (actualCount <= 0) return
        val audio = buffered.copyOf(actualCount)
        val remainingCount = bufferedSamples - audio.size
        buffered = if (remainingCount > 0) buffered.copyOfRange(audio.size, bufferedSamples) else ShortArray(0)
        bufferedSamples = buffered.size
        val rate = sampleRate
        job = scope.launch {
            runCatching { engine.transcribe(audio, rate) }
                .getOrNull()
                ?.takeIf { it.text.isNotBlank() }
                ?.let { _latest.value = it }
        }
        job?.invokeOnCompletion {
            val next = synchronized(this@AsrPipeline) {
                val requested = pendingFlushSamples
                pendingFlushSamples = 0
                requested.coerceAtMost(bufferedSamples)
            }
            if (next > 0) transcribe(next)
        }
    }

    private fun append(samples: ShortArray) {
        val required = bufferedSamples + samples.size
        if (required > buffered.size) {
            var capacity = maxOf(8_000, buffered.size * 2)
            while (capacity < required) capacity *= 2
            buffered = buffered.copyOf(capacity)
        }
        samples.copyInto(buffered, destinationOffset = bufferedSamples)
        bufferedSamples = required
    }

    private fun updatePreRoll(samples: ShortArray, limit: Int) {
        if (limit <= 0) return
        val merged = ShortArray(minOf(limit, preRoll.size + samples.size))
        val keepOld = minOf(preRoll.size, merged.size)
        if (keepOld > 0) preRoll.copyInto(merged, 0, preRoll.size - keepOld, preRoll.size)
        val copyNew = minOf(samples.size, merged.size - keepOld)
        samples.copyInto(merged, keepOld, samples.size - copyNew, samples.size)
        preRoll = merged
    }

    fun close() {
        job?.cancel()
        job = null
        pendingFlushSamples = 0
        buffered = ShortArray(0)
        bufferedSamples = 0
        preRoll = ShortArray(0)
        silenceSamples = 0
        vad.reset()
        scope.coroutineContext[Job]?.cancel()
    }
}
