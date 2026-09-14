package com.lingualive.audio

import java.io.File

object ModelInstallTransaction {
    fun prepare(root: File): File {
        val staging = File(root.parentFile ?: root, root.name + ".staging")
        if (!staging.exists()) staging.mkdirs()
        return staging
    }

    fun commit(staging: File, target: File): Boolean {
        if (!ModelDownloadValidator.isComplete(staging)) return false
        if (target.exists()) target.deleteRecursively()
        return staging.renameTo(target)
    }
}
