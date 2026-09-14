package com.lingualive.audio

import java.util.ArrayDeque

/** Bounded PCM buffer: newest audio wins when the consumer is temporarily slower. */
class PcmRingBuffer(private val maxSamples: Int) {
    private val q = ArrayDeque<Short>()
    @Synchronized fun offer(samples: ShortArray) {
        for (s in samples) {
            if (q.size >= maxSamples) q.removeFirst()
            q.addLast(s)
        }
    }
    @Synchronized fun poll(max: Int): ShortArray {
        val n = minOf(max, q.size)
        val out = ShortArray(n)
        for (i in 0 until n) out[i] = q.removeFirst()
        return out
    }
    @Synchronized fun size(): Int = q.size
    @Synchronized fun clear() = q.clear()
}
