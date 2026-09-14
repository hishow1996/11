package com.lingualive.audio

data class AsrSilencePolicy(val minRms: Float = 0.003f, val dropSilentChunks: Boolean = true)
