package com.lingualive.data

class InMemoryApiKeyStore : ApiKeyStore {
    private val values = mutableMapOf<String, String>()

    @Synchronized
    override fun get(provider: String): String? = values[provider]

    @Synchronized
    override fun put(provider: String, key: String) {
        require(key.isNotBlank()) { "API key must not be blank" }
        values[provider] = key
    }

    @Synchronized
    override fun remove(provider: String) {
        values.remove(provider)
    }
}
