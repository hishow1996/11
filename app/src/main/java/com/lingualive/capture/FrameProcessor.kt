package com.lingualive.capture

class FrameProcessor(private val intervalMs: Long = 700L) {
    private var lastProcessTime = 0L
    private var lastHash = 0

    fun shouldProcess(frame: CaptureFrame): Boolean {
        if (frame.timestampMs - lastProcessTime < intervalMs) return false
        val hash = frame.bitmap.hashCode()
        if (hash == lastHash) return false
        lastHash = hash
        lastProcessTime = frame.timestampMs
        return true
    }
}
