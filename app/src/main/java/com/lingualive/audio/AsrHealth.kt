package com.lingualive.audio

data class AsrHealth(
    val localAttempts: Long = 0,
    val localFailures: Long = 0,
    val cloudFallbacks: Long = 0,
    val lastLatencyMs: Long = 0
)
