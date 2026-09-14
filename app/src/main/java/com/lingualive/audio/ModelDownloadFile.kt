package com.lingualive.audio

import java.io.File

object ModelDownloadFile {
    fun tempFor(target: File): File = File(target.parentFile, target.name + ".part")
    fun finalize(temp: File, target: File): Boolean {
        if (!temp.isFile || temp.length() == 0L) return false
        if (target.exists()) target.delete()
        return temp.renameTo(target)
    }
}
