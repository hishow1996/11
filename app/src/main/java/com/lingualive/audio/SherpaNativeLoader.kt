package com.lingualive.audio

object SherpaNativeLoader {
    @Volatile private var loaded = false

    fun load(): Boolean {
        if (loaded) return true
        return runCatching {
            System.loadLibrary("sherpa-onnx-jni")
            loaded = true
            true
        }.getOrDefault(false)
    }
}
