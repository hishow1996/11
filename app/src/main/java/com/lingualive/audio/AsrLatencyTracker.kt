package com.lingualive.audio

class AsrLatencyTracker {
    private var startedAt = 0L
    var lastMs: Long = 0
        private set

    fun start(nowMs: Long = System.currentTimeMillis()) {
        startedAt = nowMs
    }

    fun finish(nowMs: Long = System.currentTimeMillis()): Long {
        val latency = if (startedAt > 0L) (nowMs - startedAt).coerceAtLeast(0L) else 0L
        lastMs = latency
        startedAt = 0L
        return latency
    }

    fun reset() {
        startedAt = 0L
        lastMs = 0L
    }
}