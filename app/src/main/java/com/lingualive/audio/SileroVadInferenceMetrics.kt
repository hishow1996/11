package com.lingualive.audio

class SileroVadInferenceMetrics {
    var calls: Long = 0
        private set
    var failures: Long = 0
        private set
    fun success() { calls++ }
    fun failure() { calls++; failures++ }
    fun reset() { calls = 0; failures = 0 }
}
