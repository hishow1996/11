package com.lingualive.audio

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

class SherpaVoiceActivity(
    private val scope: CoroutineScope,
    private val onPcm: (ShortArray) -> Unit
) {
    fun start(): AudioRecord {
        val sampleRate = 16_000
        val min = AudioRecord.getMinBufferSize(
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        ).coerceAtLeast(2048)
        val record = AudioRecord(
            MediaRecorder.AudioSource.DEFAULT,
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            min * 2
        )
        record.startRecording()
        scope.launch(Dispatchers.IO) {
            val buf = ShortArray(512)
            while (isActive && record.recordingState == AudioRecord.RECORDSTATE_RECORDING) {
                val n = record.read(buf, 0, buf.size)
                if (n > 0) onPcm(buf.copyOf(n))
            }
        }
        return record
    }
}
