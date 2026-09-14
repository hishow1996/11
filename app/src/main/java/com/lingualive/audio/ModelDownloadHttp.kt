package com.lingualive.audio

import java.io.File
import java.net.URL

object ModelDownloadHttp {
    fun download(url: String, target: File, onProgress: (Long, Long) -> Unit = { _, _ -> }) {
        val connection = URL(url).openConnection()
        connection.connectTimeout = 15000
        connection.readTimeout = 30000
        connection.connect()
        require(connection is java.net.HttpURLConnection && connection.responseCode in 200..299)
        val total = connection.contentLengthLong
        target.parentFile?.mkdirs()
        connection.inputStream.use { input ->
            target.outputStream().use { output ->
                val buffer = ByteArray(64 * 1024)
                var done = 0L
                while (true) {
                    val n = input.read(buffer)
                    if (n < 0) break
                    output.write(buffer, 0, n)
                    done += n
                    onProgress(done, total)
                }
            }
        }
    }
}
