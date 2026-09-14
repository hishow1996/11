package com.lingualive.audio

import android.media.AudioRecord
import android.os.SystemClock

/** Small recovery state machine for long-running AudioRecord capture. */
class AudioInputRecovery(
    private val maxConsecutiveErrors: Int = 8,
    private val retryDelayMs: Long = 120L
) {
    private var errors = 0
    private var lastErrorAt = 0L

    fun onSuccess() {
        errors = 0
    }

    fun onReadResult(count: Int): Boolean {
        if (count > 0) {
            onSuccess()
            return true
        }
        errors++
        lastErrorAt = SystemClock.elapsedRealtime()
        return errors < maxConsecutiveErrors
    }

    fun shouldRetry(): Boolean = errors in 1 until maxConsecutiveErrors &&
        SystemClock.elapsedRealtime() - lastErrorAt >= retryDelayMs

    fun reset() {
        errors = 0
        lastErrorAt = 0L
    }

    companion object {
        fun safeStop(record: AudioRecord?) {
            if (record == null) return
            runCatching { record.stop() }
        }
    }
}
