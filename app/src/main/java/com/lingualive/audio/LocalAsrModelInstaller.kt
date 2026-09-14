package com.lingualive.audio

import java.io.File
import java.io.FileInputStream
import java.security.MessageDigest

object LocalAsrModelInstaller {
    fun verify(file: File, expectedSha256: String): Boolean {
        if (!file.isFile || expectedSha256.isBlank()) return false
        val digest = MessageDigest.getInstance("SHA-256")
        FileInputStream(file).use { input ->
            val buffer = ByteArray(64 * 1024)
            while (true) {
                val n = input.read(buffer)
                if (n <= 0) break
                digest.update(buffer, 0, n)
            }
        }
        return digest.digest().joinToString("") { "%02x".format(it) }
            .equals(expectedSha256.trim(), ignoreCase = true)
    }

    fun requiredFiles(root: File): List<File> = listOf(
        File(root, "model.int8.onnx"),
        File(root, "tokens.txt"),
        File(root, "silero_vad.onnx")
    )
}
