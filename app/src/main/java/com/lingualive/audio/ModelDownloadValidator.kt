package com.lingualive.audio

import java.io.File

object ModelDownloadValidator {
    fun isComplete(root: File): Boolean =
        LocalAsrModelInstaller.requiredFiles(root).all { it.isFile && it.length() > 0L }
}
