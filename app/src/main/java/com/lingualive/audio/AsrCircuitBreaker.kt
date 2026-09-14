package com.lingualive.audio

class AsrCircuitBreaker(private val threshold: Int = 3) {
    private var failures = 0
    fun recordFailure() { failures++ }
    fun recordSuccess() { failures = 0 }
    fun open(): Boolean = failures >= threshold
}
