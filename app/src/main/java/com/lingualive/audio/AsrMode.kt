package com.lingualive.audio

enum class AsrMode { AUTO, LOCAL_FIRST, CLOUD_ONLY }

data class AsrRuntimeConfig(
    val mode: AsrMode = AsrMode.AUTO,
    val sampleRate: Int = 16_000,
    val maxUtteranceMs: Long = 8_000
)
