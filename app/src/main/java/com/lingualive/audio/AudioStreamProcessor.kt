package com.lingualive.audio

import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow

/**
 * Converts captured PCM audio frames into ASR input.
 * Filters silent frames before forwarding them.
 */
class AudioStreamProcessor(
    private val detector: VoiceActivityDetector = VoiceActivityDetector()
) {

    private val _frames = MutableSharedFlow<AudioFrame>(extraBufferCapacity = 32)
    val frames = _frames.asSharedFlow()

    fun process(samples: ShortArray, sampleRate: Int) {
        val frame = AudioFrame(
            samples = samples,
            sampleRate = sampleRate,
            timestamp = System.currentTimeMillis()
        )

        if (detector.isVoice(frame)) {
            _frames.tryEmit(frame)
        }
    }
}
