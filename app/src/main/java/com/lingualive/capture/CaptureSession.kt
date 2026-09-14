package com.lingualive.capture

class CaptureSession(private val processor: FrameProcessor) {
    private var running = false

    fun start() { running = true }
    fun stop() { running = false }
    fun isRunning(): Boolean = running

    fun submit(frame: CaptureFrame, onFrameReady: (CaptureFrame) -> Unit) {
        if (running && processor.shouldProcess(frame)) onFrameReady(frame)
    }
}
