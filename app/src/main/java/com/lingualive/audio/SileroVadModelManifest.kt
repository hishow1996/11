package com.lingualive.audio

data class SileroVadModelManifest(
    val fileName: String = "silero_vad.onnx",
    val sampleRate: Int = 16_000,
    val windowSize: Int = 512,
    val format: String = "onnx"
)
