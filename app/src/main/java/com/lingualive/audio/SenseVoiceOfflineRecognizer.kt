package com.lingualive.audio

import com.k2fsa.sherpa.onnx.OfflineModelConfig
import com.k2fsa.sherpa.onnx.OfflineRecognizer
import com.k2fsa.sherpa.onnx.OfflineRecognizerConfig
import com.k2fsa.sherpa.onnx.OfflineSenseVoiceModelConfig
import java.io.File

class SenseVoiceOfflineRecognizer(config: SenseVoiceRuntimeConfig) {
    private val recognizer: OfflineRecognizer

    init {
        require(config.valid()) { "invalid_sensevoice_config" }
        val modelConfig = OfflineModelConfig(
            senseVoice = OfflineSenseVoiceModelConfig(
                model = config.model.absolutePath,
                language = config.language,
                useInverseTextNormalization = config.useItn
            ),
            tokens = config.tokens.absolutePath,
            numThreads = config.threads,
            debug = false,
            provider = "cpu"
        )
        recognizer = OfflineRecognizer(
            config = OfflineRecognizerConfig(modelConfig = modelConfig)
        )
    }

    fun transcribe(audio: OfflineAudioChunk): SenseVoiceResult {
        require(audio.valid()) { "invalid_audio_chunk" }
        val stream = recognizer.createStream()
        try {
            stream.acceptWaveform(audio.samples, audio.sampleRate)
            recognizer.decode(stream)
            val r = recognizer.getResult(stream)
            return SenseVoiceResult(r.text, r.lang, r.emotion, r.event, r.timestamps.toList())
        } finally {
            stream.release()
        }
    }

    fun release() = recognizer.release()
}
