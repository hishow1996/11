package com.lingualive.audio

import java.io.File

data class LocalAsrModelFiles(
    val model: File,
    val tokens: File,
    val vad: File
)

object LocalAsrAvailability {
    fun find(root: File): LocalAsrModelFiles? {
        val model = File(root, "model.int8.onnx")
        val tokens = File(root, "tokens.txt")
        val vad = File(root, "silero_vad.onnx")
        return if (model.isFile && tokens.isFile && vad.isFile) {
            LocalAsrModelFiles(model, tokens, vad)
        } else null
    }
}
