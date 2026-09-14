package com.lingualive.audio

class SileroVadFrameIndex {
    private var value = 0L
    fun next(): Long = value++
    fun reset() { value = 0L }
}
