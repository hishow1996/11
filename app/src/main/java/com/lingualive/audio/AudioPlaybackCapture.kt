package com.lingualive.audio

import androidx.annotation.RequiresApi
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioPlaybackCaptureConfiguration
import android.media.AudioRecord
import android.media.projection.MediaProjection
import android.os.Build

/** Android 10+ system playback capture factory. Android 9 及以下系统不支持，调用方需做版本守卫降级。 */
@RequiresApi(Build.VERSION_CODES.Q)
class AudioPlaybackCapture {
    fun createConfiguration(projection: MediaProjection): AudioPlaybackCaptureConfiguration =
        AudioPlaybackCaptureConfiguration.Builder(projection)
            .addMatchingUsage(AudioAttributes.USAGE_MEDIA)
            .addMatchingUsage(AudioAttributes.USAGE_GAME)
            .addMatchingUsage(AudioAttributes.USAGE_UNKNOWN)
            .build()

    fun createRecord(projection: MediaProjection, config: AudioCaptureConfig = AudioCaptureConfig()): AudioRecord {
        val channelMask = if (config.channelCount == 1) AudioFormat.CHANNEL_IN_MONO else AudioFormat.CHANNEL_IN_STEREO
        val format = AudioFormat.Builder()
            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
            .setSampleRate(config.sampleRate)
            .setChannelMask(channelMask)
            .build()
        val capture = createConfiguration(projection)
        val minBuffer = AudioRecord.getMinBufferSize(config.sampleRate, channelMask, AudioFormat.ENCODING_PCM_16BIT)
        return AudioRecord.Builder()
            .setAudioFormat(format)
            .setAudioPlaybackCaptureConfig(capture)
            .setBufferSizeInBytes(minBuffer.coerceAtLeast(config.sampleRate * 2))
            .build()
    }
}
