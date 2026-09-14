package com.lingualive.audio

class SileroVadFrameBatcher(private val frameSize: Int = 512) {
    private val pending = ArrayList<Float>()
    fun push(input: FloatArray): List<FloatArray> {
        pending.ensureCapacity(pending.size + input.size)
        input.forEach { pending.add(it) }
        val out = ArrayList<FloatArray>()
        while (pending.size >= frameSize) {
            out += FloatArray(frameSize) { pending.removeAt(0) }
        }
        return out
    }
    fun clear() = pending.clear()
}
