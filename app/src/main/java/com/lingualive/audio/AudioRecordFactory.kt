package com.lingualive.audio

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder

object AudioRecordFactory {
    fun create(sampleRate: Int = 16_000): AudioRecord {
        val min = AudioRecord.getMinBufferSize(
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )
        require(min > 0) { "audio_record_unavailable" }
        return AudioRecord(
            MediaRecorder.AudioSource.DEFAULT,
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            min.coerceAtLeast(4096) * 2
        )
    }
}
