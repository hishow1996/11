package com.lingualive.translation

import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

class MicrosoftTranslationProvider : TranslationProvider {
    override val id = TranslationProviderId.MICROSOFT
    override suspend fun translate(request: TranslationRequest, config: ProviderConfig): String {
        require(config.apiKey.isNotBlank()) { "Microsoft Translator key is not configured" }
        val endpoint = config.baseUrl.ifBlank { "https://api.cognitive.microsofttranslator.com/translate" }
        val target = request.targetLanguage.substringBefore('-')
        val source = request.sourceLanguage.takeIf { it.isNotBlank() && !it.equals("auto", true) }?.substringBefore('-')
        val query = buildString {
            append("api-version=3.0&to=").append(HttpTranslation.formEncode(target))
            source?.let { append("&from=").append(HttpTranslation.formEncode(it)) }
        }
        val connection = URL("$endpoint?$query").openConnection() as HttpURLConnection
        try {
            connection.requestMethod = "POST"
            connection.connectTimeout = 8_000
            connection.readTimeout = 20_000
            connection.doOutput = true
            connection.setRequestProperty("Content-Type", "application/json")
            connection.setRequestProperty("Ocp-Apim-Subscription-Key", config.apiKey)
            connection.outputStream.use { it.write(JSONArray().put(JSONObject().put("Text", request.text)).toString().toByteArray()) }
            val code = connection.responseCode
            val stream = if (code in 200..299) connection.inputStream else connection.errorStream
            val text = stream.bufferedReader().use { it.readText() }
            if (code !in 200..299) throw TranslationException("Microsoft HTTP $code")
            val rows = JSONArray(text)
            return rows.optJSONObject(0)?.optJSONArray("translations")?.optJSONObject(0)?.optString("text")?.trim()
                .orEmpty().ifEmpty { throw TranslationException("Microsoft returned empty translation") }
        } finally { connection.disconnect() }
    }
}

class BaiduTranslationProvider : TranslationProvider {
    override val id = TranslationProviderId.BAIDU
    override suspend fun translate(request: TranslationRequest, config: ProviderConfig): String {
        require(config.apiKey.contains(':')) { "Baidu config must be appId:secretKey" }
        val parts = config.apiKey.split(':', limit = 2)
        val appId = parts[0]
        val secret = parts[1]
        val salt = System.currentTimeMillis().toString()
        val from = if (request.sourceLanguage.equals("auto", true)) "auto" else request.sourceLanguage.substringBefore('-')
        val to = request.targetLanguage.substringBefore('-').lowercase()
        val sign = md5(appId + request.text + salt + secret)
        val endpoint = config.baseUrl.ifBlank { "https://fanyi-api.baidu.com/api/trans/vip/translate" }
        val url = endpoint + "?q=${HttpTranslation.formEncode(request.text)}&from=$from&to=$to&appid=$appId&salt=$salt&sign=$sign"
        val json = HttpTranslation.getJson(url)
        val rows = json.optJSONArray("trans_result") ?: throw TranslationException("Baidu returned an error")
        return buildString { for (i in 0 until rows.length()) append(rows.optJSONObject(i)?.optString("dst").orEmpty()) }
            .trim().ifEmpty { throw TranslationException("Baidu returned empty translation") }
    }

    private fun md5(value: String): String = java.security.MessageDigest.getInstance("MD5")
        .digest(value.toByteArray()).joinToString("") { "%02x".format(it) }
}

class ModernMtTranslationProvider : TranslationProvider {
    override val id = TranslationProviderId.MODERNMT
    override suspend fun translate(request: TranslationRequest, config: ProviderConfig): String {
        require(config.apiKey.isNotBlank()) { "ModernMT API key is not configured" }
        val endpoint = config.baseUrl.ifBlank { "https://api.modernmt.com/translate" }
        val body = JSONObject().put("q", request.text)
            .put("source", request.sourceLanguage.takeIf { !it.equals("auto", true) } ?: "auto")
            .put("target", request.targetLanguage.substringBefore('-'))
        val json = HttpTranslation.postJson(endpoint, config.apiKey, body)
        return json.optString("data").trim().ifEmpty { throw TranslationException("ModernMT returned empty translation") }
    }
}
