package com.lingualive.audio

object SileroVadRuntimeFactory {
    fun create(inference: SileroVadInferencePort): SileroVadInferencePort =
        SileroVadRuntimeAdapter(inference)
}
