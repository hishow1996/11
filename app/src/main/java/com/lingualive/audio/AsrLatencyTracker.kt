package com.lingualive.audio

class AsrLatencyTracker {
    private var started = 0L
    var lastMs: Long = 0
        private set

    fun start(nowMs: Long = System.currentTimeMillis()) { started = nowMs }
    fun finish(nowMs: Long = System.currentTimeMillis()) {
        if (started > 0) lastMs = (nowMs - started).coerceAtLeast(0)
        started = 0
    }
}
