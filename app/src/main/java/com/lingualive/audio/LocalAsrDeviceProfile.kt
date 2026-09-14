package com.lingualive.audio

import android.os.Build

data class LocalAsrDeviceProfile(
    val abi: String,
    val sdk: Int,
    val recommendedThreads: Int
)

object LocalAsrDeviceProfileProvider {
    fun current(): LocalAsrDeviceProfile {
        val abi = Build.SUPPORTED_ABIS.firstOrNull() ?: "unknown"
        val threads = Runtime.getRuntime().availableProcessors().coerceIn(1, 4)
        return LocalAsrDeviceProfile(abi, Build.VERSION.SDK_INT, threads)
    }
}
