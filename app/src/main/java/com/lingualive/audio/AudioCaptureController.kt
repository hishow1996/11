package com.lingualive.audio

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.projection.MediaProjection
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

class AudioCaptureController(
    private val projection: MediaProjection,
    private val config: AudioCaptureConfig = AudioCaptureConfig(),
    private val onChunk: suspend (PcmChunk) -> Unit
) {
    private var record: AudioRecord? = null
    private var job: Job? = null

    fun start(scope: CoroutineScope) {
        if (job != null) return
        val captureConfig = AudioPlaybackCapture().createConfiguration(projection)
        val minBuffer = AudioRecord.getMinBufferSize(
            config.sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )
        val chunkSamples = (config.sampleRate * config.chunkMs / 1000L).toInt()
        val bufferSamples = maxOf(minBuffer / 2, chunkSamples)
        record = AudioRecord.Builder()
            .setAudioFormat(
                AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(config.sampleRate)
                    .setChannelMask(AudioFormat.CHANNEL_IN_MONO)
                    .build()
            )
            .setBufferSizeInBytes(bufferSamples * 2)
            .setAudioPlaybackCaptureConfig(captureConfig)
            .build()
        record?.startRecording()
        job = scope.launch(Dispatchers.IO) {
            val buffer = ShortArray(chunkSamples)
            while (isActive) {
                val count = record?.read(buffer, 0, buffer.size) ?: 0
                if (count > 0) onChunk(PcmChunk(buffer.copyOf(count), config.sampleRate, System.currentTimeMillis()))
            }
        }
    }

    suspend fun stop() {
        job?.cancelAndJoin()
        job = null
        record?.runCatching { stop() }
        record?.release()
        record = null
    }
}
