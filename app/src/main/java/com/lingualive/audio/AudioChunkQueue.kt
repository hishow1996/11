package com.lingualive.audio

import java.util.ArrayDeque

/** Bounded PCM queue. Capture never grows memory without limit when ASR/network is slower. */
class AudioChunkQueue(private val maxChunks: Int = 24) {
    private val queue = ArrayDeque<PcmChunk>()
    private var dropped = 0L

    @Synchronized
    fun offer(chunk: PcmChunk) {
        if (chunk.samples.isEmpty()) return
        while (queue.size >= maxChunks) {
            queue.removeFirst()
            dropped++
        }
        queue.addLast(chunk)
    }

    @Synchronized
    fun poll(): PcmChunk? = if (queue.isEmpty()) null else queue.removeFirst()

    @Synchronized
    fun clear() {
        queue.clear()
    }

    @Synchronized
    fun size(): Int = queue.size

    @Synchronized
    fun droppedChunks(): Long = dropped
}
