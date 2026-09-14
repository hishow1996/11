package com.lingualive.audio

class UtteranceBuffer(private val maxSamples: Int = 128_000) {
    private val data = ArrayList<Short>(maxSamples)

    @Synchronized
    fun append(samples: ShortArray) {
        for (s in samples) {
            if (data.size >= maxSamples) data.removeAt(0)
            data.add(s)
        }
    }

    @Synchronized
    fun take(): ShortArray {
        val out = ShortArray(data.size)
        for (i in data.indices) out[i] = data[i]
        data.clear()
        return out
    }

    @Synchronized fun size(): Int = data.size
    @Synchronized fun clear() = data.clear()
}
