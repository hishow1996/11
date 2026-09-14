package com.lingualive.translation

import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder

internal object HttpTranslation {
    private fun read(connection: HttpURLConnection): String {
        val code = connection.responseCode
        val stream = if (code in 200..299) connection.inputStream else connection.errorStream
        val text = BufferedReader(InputStreamReader(stream, Charsets.UTF_8)).use { it.readText() }
        if (code !in 200..299) throw TranslationException("HTTP $code: ${text.take(300)}")
        return text
    }

    fun postJson(url: String, apiKey: String, body: JSONObject): JSONObject {
        val connection = URL(url).openConnection() as HttpURLConnection
        try {
            connection.requestMethod = "POST"
            connection.connectTimeout = 8_000
            connection.readTimeout = 20_000
            connection.doOutput = true
            connection.setRequestProperty("Content-Type", "application/json")
            if (apiKey.isNotBlank()) connection.setRequestProperty("Authorization", "Bearer $apiKey")
            connection.outputStream.use { it.write(body.toString().toByteArray(Charsets.UTF_8)) }
            return JSONObject(read(connection))
        } catch (e: TranslationException) {
            throw e
        } catch (e: Exception) {
            throw TranslationException("network error", e)
        } finally {
            connection.disconnect()
        }
    }

    fun postJsonArray(url: String, apiKey: String, body: JSONArray, headers: Map<String, String> = emptyMap()): JSONArray {
        val connection = URL(url).openConnection() as HttpURLConnection
        try {
            connection.requestMethod = "POST"
            connection.connectTimeout = 8_000
            connection.readTimeout = 20_000
            connection.doOutput = true
            connection.setRequestProperty("Content-Type", "application/json")
            if (apiKey.isNotBlank()) connection.setRequestProperty("Authorization", "Bearer $apiKey")
            headers.forEach { (name, value) -> connection.setRequestProperty(name, value) }
            connection.outputStream.use { it.write(body.toString().toByteArray(Charsets.UTF_8)) }
            return JSONArray(read(connection))
        } finally {
            connection.disconnect()
        }
    }

    fun getJson(url: String, apiKey: String = ""): JSONObject {
        val connection = URL(url).openConnection() as HttpURLConnection
        try {
            connection.requestMethod = "GET"
            connection.connectTimeout = 8_000
            connection.readTimeout = 20_000
            if (apiKey.isNotBlank()) connection.setRequestProperty("Authorization", "Bearer $apiKey")
            return JSONObject(read(connection))
        } finally {
            connection.disconnect()
        }
    }

    fun formEncode(value: String): String = URLEncoder.encode(value, "UTF-8")

    fun extractChatText(json: JSONObject): String = json.optJSONArray("choices")
        ?.optJSONObject(0)?.optJSONObject("message")?.optString("content")?.trim().orEmpty()
        .ifEmpty { throw TranslationException("provider returned empty translation") }

    fun extractGoogleText(json: JSONObject): String {
        val rows = json.optJSONObject("data")?.optJSONArray("translations") ?: JSONArray()
        return buildString { for (i in 0 until rows.length()) append(rows.optJSONObject(i)?.optString("translatedText").orEmpty()) }
            .trim().ifEmpty { throw TranslationException("Google returned empty translation") }
    }
}
