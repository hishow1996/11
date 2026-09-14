package com.lingualive.settings

import android.content.Context
import android.util.Base64
import com.lingualive.translation.ProviderConfig
import com.lingualive.translation.TranslationProviderId
import org.json.JSONObject
import java.nio.charset.StandardCharsets
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties

class SettingsStore(context: Context) {
    private val prefs = context.applicationContext.getSharedPreferences("lingualive_settings", Context.MODE_PRIVATE)
    private val keyAlias = "lingualive_settings_key"
    fun getBoolean(name: String, default: Boolean) = prefs.getBoolean(name, default)
    fun setBoolean(name: String, value: Boolean) { prefs.edit().putBoolean(name, value).apply() }
    fun getString(name: String, default: String) = prefs.getString(name, default) ?: default
    fun setString(name: String, value: String) { prefs.edit().putString(name, value).apply() }
    fun getFloat(name: String, default: Float) = prefs.getFloat(name, default)
    fun setFloat(name: String, value: Float) { prefs.edit().putFloat(name, value).apply() }
    fun providerConfig(id: TranslationProviderId): ProviderConfig {
        val json = JSONObject(prefs.getString("provider_${id.name}", "{}") ?: "{}")
        return ProviderConfig(decrypt(json.optString("key")), json.optString("baseUrl"), json.optString("model"))
    }
    fun saveProvider(id: TranslationProviderId, config: ProviderConfig) {
        val json = JSONObject().put("key", encrypt(config.apiKey)).put("baseUrl", config.baseUrl).put("model", config.model)
        prefs.edit().putString("provider_${id.name}", json.toString()).apply()
    }
    private fun key(): SecretKey {
        val ks = java.security.KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        (ks.getKey(keyAlias, null) as? SecretKey)?.let { return it }
        val gen = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
        gen.init(KeyGenParameterSpec.Builder(keyAlias, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT).setBlockModes(KeyProperties.BLOCK_MODE_GCM).setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).build())
        return gen.generateKey()
    }
    private fun encrypt(value: String): String {
        if (value.isBlank()) return ""
        val cipher = Cipher.getInstance("AES/GCM/NoPadding").apply { init(Cipher.ENCRYPT_MODE, key()) }
        return Base64.encodeToString(cipher.iv + cipher.doFinal(value.toByteArray(StandardCharsets.UTF_8)), Base64.NO_WRAP)
    }
    private fun decrypt(value: String): String = runCatching {
        if (value.isBlank()) return ""
        val bytes = Base64.decode(value, Base64.NO_WRAP)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding").apply { init(Cipher.DECRYPT_MODE, key(), GCMParameterSpec(128, bytes.copyOfRange(0, 12))) }
        String(cipher.doFinal(bytes.copyOfRange(12, bytes.size)), StandardCharsets.UTF_8)
    }.getOrDefault("")
}
