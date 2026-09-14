package com.lingualive.translation

import org.json.JSONObject

class DeepLTranslationProvider : TranslationProvider {
    override val id = TranslationProviderId.DEEPL
    override suspend fun translate(request: TranslationRequest, config: ProviderConfig): String {
        require(config.apiKey.isNotBlank()) { "DeepL API key is not configured" }
        val url = config.baseUrl.ifBlank { "https://api-free.deepl.com/v2/translate" }
        val connection = java.net.URL(url).openConnection() as java.net.HttpURLConnection
        try {
            connection.requestMethod = "POST"
            connection.connectTimeout = 8_000
            connection.readTimeout = 20_000
            connection.doOutput = true
            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded")
            connection.setRequestProperty("Authorization", "DeepL-Auth-Key ${config.apiKey}")
            val target = request.targetLanguage.substringBefore('-').uppercase()
            val form = "text=${HttpTranslation.formEncode(request.text)}&target_lang=${HttpTranslation.formEncode(target)}"
            connection.outputStream.use { it.write(form.toByteArray()) }
            val code = connection.responseCode
            val stream = if (code in 200..299) connection.inputStream else connection.errorStream
            val text = stream.bufferedReader().use { it.readText() }
            if (code !in 200..299) throw TranslationException("DeepL HTTP $code")
            return JSONObject(text).optJSONArray("translations")?.optJSONObject(0)?.optString("text")?.trim()
                .orEmpty().ifEmpty { throw TranslationException("DeepL returned empty translation") }
        } finally { connection.disconnect() }
    }
}

class GoogleTranslationProvider : TranslationProvider {
    override val id = TranslationProviderId.GOOGLE
    override suspend fun translate(request: TranslationRequest, config: ProviderConfig): String {
        require(config.apiKey.isNotBlank()) { "Google API key is not configured" }
        val lang = request.targetLanguage.replace('-', '_')
        val url = (config.baseUrl.ifBlank { "https://translation.googleapis.com/language/translate/v2" }) +
            "?key=${HttpTranslation.formEncode(config.apiKey)}&q=${HttpTranslation.formEncode(request.text)}&target=${HttpTranslation.formEncode(lang)}"
        return HttpTranslation.extractGoogleText(HttpTranslation.getJson(url))
    }
}
