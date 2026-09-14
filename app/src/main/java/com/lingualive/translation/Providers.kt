package com.lingualive.translation

import org.json.JSONArray
import org.json.JSONObject

abstract class ChatTranslationProvider(
    override val id: TranslationProviderId,
    private val defaultUrl: String,
    private val defaultModel: String
) : TranslationProvider {
    override suspend fun translate(request: TranslationRequest, config: ProviderConfig): String {
        require(config.apiKey.isNotBlank()) { "${id.name} API key is not configured" }
        val url = config.baseUrl.ifBlank { defaultUrl }.trimEnd('/') + "/chat/completions"
        val body = JSONObject().put("model", config.model.ifBlank { defaultModel }).put("temperature", 0)
            .put("messages", JSONArray()
                .put(JSONObject().put("role", "system").put("content", "Translate faithfully to ${request.targetLanguage}. Return translation only."))
                .put(JSONObject().put("role", "user").put("content", request.text)))
        return HttpTranslation.extractChatText(HttpTranslation.postJson(url, config.apiKey, body))
    }
}

class OpenAiTranslationProvider : ChatTranslationProvider(TranslationProviderId.OPENAI, "https://api.openai.com/v1", "gpt-4o-mini")
class DeepSeekTranslationProvider : ChatTranslationProvider(TranslationProviderId.DEEPSEEK, "https://api.deepseek.com/v1", "deepseek-chat")

class LocalTranslationProvider : TranslationProvider {
    override val id = TranslationProviderId.LOCAL
    override suspend fun translate(request: TranslationRequest, config: ProviderConfig): String =
        throw TranslationException("Local translation engine is not installed yet")
}
