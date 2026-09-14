package com.lingualive.audio

import java.util.ArrayDeque

class AsrDecodeQueue(private val maxSize: Int = 2) {
    private val queue = ArrayDeque<AsrDecodeRequest>()

    @Synchronized
    fun offer(request: AsrDecodeRequest): Boolean {
        if (queue.size >= maxSize) return false
        queue.addLast(request)
        return true
    }

    @Synchronized
    fun poll(): AsrDecodeRequest? = if (queue.isEmpty()) null else queue.removeFirst()

    @Synchronized
    fun clear() = queue.clear()
}
