package com.lingualive.data

/**
 * Small abstraction for API credentials.
 * The Android implementation can back this with encrypted storage.
 */
interface ApiKeyStore {
    fun get(provider: String): String?
    fun put(provider: String, key: String)
    fun remove(provider: String)
}
