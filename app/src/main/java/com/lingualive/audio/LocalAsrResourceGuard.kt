package com.lingualive.audio

class LocalAsrResourceGuard {
    private var released = false
    fun check() {
        check(!released) { "local_asr_resource_released" }
    }
    fun release() { released = true }
}
