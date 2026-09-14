package com.lingualive.audio

data class SileroVadAssetSpec(
    val fileName: String = "silero_vad.onnx",
    val sampleRate: Int = 16_000,
    val modelVersion: String = "v4"
)
