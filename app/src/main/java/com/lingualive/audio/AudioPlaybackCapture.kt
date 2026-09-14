package com.lingualive.audio

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioPlaybackCaptureConfiguration
import android.media.AudioRecord
import android.media.projection.MediaProjection
import android.os.Build
import androidx.annotation.RequiresApi

/** Android 10+ system playback capture. Android 9 stays supported by the app but cannot capture other apps' playback. */
@RequiresApi(Build.VERSION_CODES.Q)
class AudioPlaybackCapture {
    fun createConfiguration(projection: MediaProjection): AudioPlaybackCaptureConfiguration =
        AudioPlaybackCaptureConfiguration.Builder(projection)
            .addMatchingUsage(AudioAttributes.USAGE_MEDIA)
            .addMatchingUsage(AudioAttributes.USAGE_GAME)
            .addMatchingUsage(AudioAttributes.USAGE_UNKNOWN)
            .build()

    fun createRecord(
        projection: MediaProjection,
        config: AudioCaptureConfig = AudioCaptureConfig()
    ): AudioRecord {
        require(config.sampleRate in 8_000..48_000) { "Unsupported sample rate" }
        val channelMask = if (config.channelCount == 1) AudioFormat.CHANNEL_IN_MONO else AudioFormat.CHANNEL_IN_STEREO
        val format = AudioFormat.Builder()
            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
            .setSampleRate(config.sampleRate)
            .setChannelMask(channelMask)
            .build()
        val minBuffer = AudioRecord.getMinBufferSize(config.sampleRate, channelMask, AudioFormat.ENCODING_PCM_16BIT)
        require(minBuffer > 0) { "AudioRecord buffer is unavailable" }
        return AudioRecord.Builder()
            .setAudioFormat(format)
            .setAudioPlaybackCaptureConfig(createConfiguration(projection))
            .setBufferSizeInBytes(maxOf(minBuffer * 2, config.sampleRate / 2))
            .build()
            .also { require(it.state == AudioRecord.STATE_INITIALIZED) { "Audio playback capture failed to initialize" } }
    }
}
