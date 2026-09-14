package com.lingualive.audio

data class SileroVadResultModel(
    val isSpeech: Boolean,
    val probability: Float,
    val startSample: Long,
    val endSample: Long
)