package com.lingualive.audio

import java.io.File

data class SenseVoiceRuntimeConfig(
    val model: File,
    val tokens: File,
    val language: String = "auto",
    val useItn: Boolean = true,
    val threads: Int = 2
) {
    fun valid() = model.isFile && tokens.isFile && threads in 1..4
}
