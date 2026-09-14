package com.lingualive.audio
object AudioChannelDownmixer {
    fun stereoToMono(input: FloatArray): FloatArray {
        val n = input.size / 2
        if (n == 0) return FloatArray(0)
        val out = FloatArray(n)
        for (i in 0 until n) out[i] = (input[i * 2] + input[i * 2 + 1]) * 0.5f
        return out
    }
}