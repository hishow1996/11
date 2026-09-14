package com.lingualive.audio
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.projection.MediaProjection
import android.os.Build

object PlaybackCaptureBuilderCompat {
    fun create(projection: MediaProjection, sampleRate: Int = 16_000): AudioRecord? {
        if (Build.VERSION.SDK_INT < 29) return null
        val capture = android.media.AudioPlaybackCaptureConfiguration.Builder(projection)
            .addMatchingUsage(AudioAttributes.USAGE_MEDIA)
            .addMatchingUsage(AudioAttributes.USAGE_GAME)
            .build()
        val size = AudioRecord.getMinBufferSize(
            sampleRate, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT
        )
        if (size <= 0) return null
        val format = AudioFormat.Builder()
            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
            .setSampleRate(sampleRate)
            .setChannelMask(AudioFormat.CHANNEL_IN_MONO)
            .build()
        return AudioRecord.Builder()
            .setAudioFormat(format)
            .setBufferSizeInBytes(size.coerceAtLeast(4096) * 2)
            .setAudioPlaybackCaptureConfig(capture)
            .build()
    }
}