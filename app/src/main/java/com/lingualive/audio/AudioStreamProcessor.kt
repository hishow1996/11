package com.lingualive.audio

/**
 * Converts captured PCM audio frames into ASR input.
 */
class AudioStreamProcessor {

    private var listener: ((AudioFrame) -> Unit)? = null

    fun setListener(callback: (AudioFrame) -> Unit) {
        listener = callback
    }

    fun process(samples: ShortArray, sampleRate: Int) {
        listener?.invoke(
            AudioFrame(
                samples = samples,
                sampleRate = sampleRate,
                timestamp = System.currentTimeMillis()
            )
        )
    }
}
