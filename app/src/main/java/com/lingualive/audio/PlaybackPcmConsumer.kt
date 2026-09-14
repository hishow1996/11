package com.lingualive.audio
fun interface PlaybackPcmConsumer {
    fun onPcm(samples: FloatArray)
}