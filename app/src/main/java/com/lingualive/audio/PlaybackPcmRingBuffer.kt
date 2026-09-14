package com.lingualive.audio

class PlaybackPcmRingBuffer(private val capacity: Int = 64000) {
    private val data = FloatArray(capacity)
    private var read = 0
    private var write = 0
    private var size = 0

    @Synchronized fun offer(input: FloatArray): Int {
        var accepted = 0
        for (v in input) {
            if (size == capacity) break
            data[write] = v
            write = (write + 1) % capacity
            size++
            accepted++
        }
        return accepted
    }

    @Synchronized fun poll(maxSamples: Int): FloatArray {
        val n = minOf(maxSamples, size)
        val out = FloatArray(n)
        for (i in 0 until n) {
            out[i] = data[read]
            read = (read + 1) % capacity
        }
        size -= n
        return out
    }

    @Synchronized fun size(): Int = size
    @Synchronized fun clear() { read = 0; write = 0; size = 0 }
}