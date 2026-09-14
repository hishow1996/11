package com.lingualive.audio

class AudioHealthMonitor(
    private val maxSilentChunks: Int = 20
) {
    private var silentChunks = 0
    var restartRequested: Boolean = false
        private set

    fun onChunk(level: AudioLevelMeter) {
        if (level.rms < 0.0005) silentChunks++ else silentChunks = 0
        if (silentChunks >= maxSilentChunks) {
            restartRequested = true
            silentChunks = 0
        }
    }

    fun acknowledgeRestart() {
        restartRequested = false
    }
}
