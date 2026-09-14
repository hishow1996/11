package com.lingualive.audio
import android.media.AudioRecord
class PlaybackCaptureReader(private val record: AudioRecord, private val onPcm: (ShortArray) -> Unit) {
    fun readLoop(keepRunning: () -> Boolean) {
        val buffer = ShortArray(512)
        while (keepRunning()) {
            val n = record.read(buffer, 0, buffer.size)
            if (n > 0) onPcm(buffer.copyOf(n)) else if (n < 0) break
        }
    }
}