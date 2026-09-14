package com.lingualive.audio

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder

class AudioRecordManager {

    private var recorder: AudioRecord? = null
    private var running = false

    fun start(onFrame: (AudioFrame) -> Unit) {
        if (running) return

        val sampleRate = 16000
        val bufferSize = AudioRecord.getMinBufferSize(
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )

        recorder = AudioRecord(
            MediaRecorder.AudioSource.DEFAULT,
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize
        )

        running = true
        recorder?.startRecording()

        Thread {
            val buffer = ShortArray(bufferSize)
            while (running) {
                val count = recorder?.read(buffer, 0, buffer.size) ?: 0
                if (count > 0) {
                    onFrame(
                        AudioFrame(
                            samples = buffer.copyOf(count),
                            sampleRate = sampleRate,
                            timestamp = System.currentTimeMillis()
                        )
                    )
                }
            }
        }.start()
    }

    fun stop() {
        running = false
        recorder?.stop()
        recorder?.release()
        recorder = null
    }
}
