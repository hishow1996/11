package com.lingualive.audio

import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow

/** Converts captured PCM audio frames into ASR input and filters silence. */
class AudioStreamProcessor(
    private val detector: VoiceActivityDetector = VoiceActivityDetector()
) {
    private val _frames = MutableSharedFlow<AudioFrame>(extraBufferCapacity = 32)
    val frames = _frames.asSharedFlow()

    fun process(samples: ShortArray, sampleRate: Int) {
        if (!detector.hasVoice(samples, sampleRate)) return
        _frames.tryEmit(
            AudioFrame(
                samples = samples.copyOf(),
                sampleRate = sampleRate,
                timestamp = System.currentTimeMillis()
            )
        )
    }
}
