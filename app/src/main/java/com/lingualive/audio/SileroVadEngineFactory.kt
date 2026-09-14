package com.lingualive.audio

object SileroVadEngineFactory {
    fun create(inference: SileroVadInferencePort): SileroVadEngine =
        SileroVadEngine(inference)
}