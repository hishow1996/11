package com.lingualive.audio

import com.k2fsa.sherpa.onnx.SileroVadModelConfig
import com.k2fsa.sherpa.onnx.Vad
import com.k2fsa.sherpa.onnx.VadModelConfig

/** Real sherpa-onnx Silero VAD bridge. Requires the official Android AAR. */
class SherpaOnnxVadInference(
    config: com.lingualive.audio.SileroVadModelConfig
) : SileroVadInferencePort {
    private val vad = Vad(
        config = VadModelConfig(
            sileroVadModelConfig = SileroVadModelConfig(
                model = config.modelPath,
                threshold = config.threshold,
                minSilenceDuration = config.minSilenceDurationSec,
                minSpeechDuration = config.minSpeechDurationSec,
                windowSize = config.windowSamples,
                maxSpeechDuration = config.maxSpeechDurationSec
            ),
            sampleRate = config.sampleRate,
            numThreads = config.numThreads,
            provider = "cpu"
        )
    )

    override fun probability(samples: FloatArray): Float = vad.compute(samples).coerceIn(0f, 1f)

    override fun reset() = vad.reset()

    fun acceptWaveform(samples: FloatArray) = vad.acceptWaveform(samples)

    fun isSpeechDetected(): Boolean = vad.isSpeechDetected()

    fun release() = vad.release()
}
