package com.lingualive.audio

class SileroVadSessionController {
    var state: SileroVadSessionState = SileroVadSessionState.NEW
        private set
    fun ready() { state = SileroVadSessionState.READY }
    fun start() { if (state == SileroVadSessionState.READY) state = SileroVadSessionState.RUNNING }
    fun flushing() { if (state == SileroVadSessionState.RUNNING) state = SileroVadSessionState.FLUSHING }
    fun close() { state = SileroVadSessionState.CLOSED }
    fun reset() { state = SileroVadSessionState.NEW }
}
