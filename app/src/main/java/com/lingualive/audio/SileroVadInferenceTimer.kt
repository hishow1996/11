package com.lingualive.audio

class SileroVadInferenceTimer {
    private var started = 0L
    fun start(now: Long = System.currentTimeMillis()) { started = now }
    fun elapsed(now: Long = System.currentTimeMillis()): Long = if (started == 0L) 0L else (now - started).coerceAtLeast(0L)
    fun reset() { started = 0L }
}
