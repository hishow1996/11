package com.lingualive.audio
class PlaybackPcmFrameCounter {
    var frames: Long = 0
        private set
    fun add(count: Int) { if (count > 0) frames += count }
    fun reset() { frames = 0 }
}