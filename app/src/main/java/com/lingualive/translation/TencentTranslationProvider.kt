package com.lingualive.translation

import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.nio.charset.StandardCharsets
import java.time.Instant
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

class TencentTranslationProvider : TranslationProvider {
    override val id = TranslationProviderId.TENCENT

    override suspend fun translate(request: TranslationRequest, config: ProviderConfig): String {
        require(config.apiKey.contains(':')) { "Tencent config must be secretId:secretKey" }
        val credentials = config.apiKey.split(':', limit = 2)
        val secretId = credentials[0]
        val secretKey = credentials[1]
        val endpoint = config.baseUrl.ifBlank { "https://mps.tencentcloudapi.com" }
        val host = URL(endpoint).host
        val service = "mps"
        val action = "TextTranslation"
        val version = "2019-06-12"
        val now = Instant.now()
        val timestamp = now.epochSecond
        val date = DateTimeFormatter.ofPattern("yyyy-MM-dd").withZone(ZoneOffset.UTC).format(now)
        val body = JSONObject()
            .put("SourceText", request.text)
            .put("Source", request.sourceLanguage.takeIf { !it.equals("auto", true) }?.substringBefore('-') ?: "auto")
            .put("Target", request.targetLanguage.substringBefore('-'))
            .toString()
        val contentType = "application/json; charset=utf-8"
        val canonicalHeaders = "content-type:$contentType\nhost:$host\n"
        val signedHeaders = "content-type;host"
        val canonicalRequest = "POST\n/\n\n$canonicalHeaders\n$signedHeaders\n${sha256(body)}"
        val credentialScope = "$date/$service/tc3_request"
        val stringToSign = "TC3-HMAC-SHA256\n$timestamp\n$credentialScope\n${sha256(canonicalRequest)}"
        val secretDate = hmac("TC3$secretKey", date)
        val secretService = hmac(secretDate, service)
        val secretSigning = hmac(secretService, "tc3_request")
        val signature = hmac(secretSigning, stringToSign).joinToString("") { "%02x".format(it) }
        val authorization = "TC3-HMAC-SHA256 Credential=$secretId/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature"

        val connection = URL(endpoint).openConnection() as HttpURLConnection
        try {
            connection.requestMethod = "POST"
            connection.connectTimeout = 8_000
            connection.readTimeout = 20_000
            connection.doOutput = true
            connection.setRequestProperty("Content-Type", contentType)
            connection.setRequestProperty("Host", host)
            connection.setRequestProperty("X-TC-Action", action)
            connection.setRequestProperty("X-TC-Version", version)
            connection.setRequestProperty("X-TC-Timestamp", timestamp.toString())
            connection.setRequestProperty("Authorization", authorization)
            connection.outputStream.use { it.write(body.toByteArray(StandardCharsets.UTF_8)) }
            val code = connection.responseCode
            val stream = if (code in 200..299) connection.inputStream else connection.errorStream
            val response = stream.bufferedReader().use { it.readText() }
            if (code !in 200..299) throw TranslationException("Tencent HTTP $code")
            return JSONObject(response).optJSONObject("Response")?.optString("TargetText")?.trim()
                .orEmpty().ifEmpty { throw TranslationException("Tencent returned empty translation") }
        } finally { connection.disconnect() }
    }

    private fun hmac(key: String, data: String): ByteArray = hmac(key.toByteArray(StandardCharsets.UTF_8), data)
    private fun hmac(key: ByteArray, data: String): ByteArray {
        val mac = Mac.getInstance("HmacSHA256")
        mac.init(SecretKeySpec(key, "HmacSHA256"))
        return mac.doFinal(data.toByteArray(StandardCharsets.UTF_8))
    }
    private fun sha256(value: String): String = java.security.MessageDigest.getInstance("SHA-256")
        .digest(value.toByteArray(StandardCharsets.UTF_8)).joinToString("") { "%02x".format(it) }
}
