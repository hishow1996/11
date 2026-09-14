package com.lingualive.audio

import com.lingualive.settings.SettingsStore
import com.lingualive.translation.TranslationProviderId
import java.io.ByteArrayOutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.nio.ByteBuffer
import java.nio.ByteOrder
import org.json.JSONObject

class OpenAiWhisperEngine(private val settings: SettingsStore) : AsrEngine {
    override val id = "openai-whisper"

    override suspend fun transcribe(audio: ShortArray, sampleRate: Int): AsrResult? {
        val config = settings.providerConfig(TranslationProviderId.OPENAI)
        if (config.apiKey.isBlank() || audio.isEmpty()) return null
        val base = config.baseUrl.trim().trimEnd('/').ifBlank { "https://api.openai.com" }
        val endpoint = if (base.endsWith("/v1")) "$base/audio/transcriptions" else "$base/v1/audio/transcriptions"
        val model = config.model.trim().ifBlank { "whisper-1" }
        val wav = wav(audio, sampleRate)
        repeat(2) { attempt ->
            val result = runCatching { request(endpoint, config.apiKey, model, wav, attempt) }.getOrNull()
            if (result != null) return result
        }
        return null
    }

    private fun request(endpoint: String, key: String, model: String, wav: ByteArray, attempt: Int): AsrResult? {
        val boundary = "----LinguaLive${System.nanoTime()}"
        val c = URL(endpoint).openConnection() as HttpURLConnection
        try {
            c.requestMethod = "POST"
            c.connectTimeout = 8_000
            c.readTimeout = 30_000
            c.doOutput = true
            c.setRequestProperty("Authorization", "Bearer $key")
            c.setRequestProperty("Content-Type", "multipart/form-data; boundary=$boundary")
            c.outputStream.use { out ->
                out.write("--$boundary\r\nContent-Disposition: form-data; name=\"file\"; filename=\"live.wav\"\r\nContent-Type: audio/wav\r\n\r\n".toByteArray())
                out.write(wav)
                out.write("\r\n--$boundary\r\nContent-Disposition: form-data; name=\"model\"\r\n\r\n$model\r\n--$boundary--\r\n".toByteArray())
            }
            val code = c.responseCode
            if (code == 429 || code >= 500) {
                if (attempt == 0) Thread.sleep(350)
                return null
            }
            if (code !in 200..299) return null
            val text = c.inputStream.bufferedReader().use { it.readText() }
            return JSONObject(text).optString("text").trim().takeIf { it.isNotBlank() }?.let(::AsrResult)
        } finally {
            c.disconnect()
        }
    }

    private fun wav(samples: ShortArray, rate: Int): ByteArray {
        val b = ByteArrayOutputStream()
        b.write("RIFF".toByteArray())
        val data = samples.size * 2
        b.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(36 + data).array())
        b.write("WAVEfmt ".toByteArray())
        b.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(16).array())
        b.write(ByteBuffer.allocate(2).order(ByteOrder.LITTLE_ENDIAN).putShort(1).array())
        b.write(ByteBuffer.allocate(2).order(ByteOrder.LITTLE_ENDIAN).putShort(1).array())
        b.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(rate).array())
        b.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(rate * 2).array())
        b.write(ByteBuffer.allocate(2).order(ByteOrder.LITTLE_ENDIAN).putShort(2).array())
        b.write(ByteBuffer.allocate(2).order(ByteOrder.LITTLE_ENDIAN).putShort(16).array())
        b.write("data".toByteArray())
        b.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(data).array())
        for (s in samples) b.write(ByteBuffer.allocate(2).order(ByteOrder.LITTLE_ENDIAN).putShort(s).array())
        return b.toByteArray()
    }
}
