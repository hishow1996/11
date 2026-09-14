package com.lingualive.audio

interface SileroVadModelLoader {
    fun load(config: SileroVadModelConfig): SileroVadInferencePort
}