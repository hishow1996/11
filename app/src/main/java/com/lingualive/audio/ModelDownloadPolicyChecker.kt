package com.lingualive.audio

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities

object ModelDownloadPolicyChecker {
    fun allowed(context: Context, policy: LocalModelPolicy): Boolean {
        if (policy == LocalModelPolicy.NEVER) return false
        if (policy == LocalModelPolicy.ANY_NETWORK || policy == LocalModelPolicy.ALWAYS_LOCAL) return true
        val cm = context.getSystemService(ConnectivityManager::class.java) ?: return false
        val network = cm.activeNetwork ?: return false
        val caps = cm.getNetworkCapabilities(network) ?: return false
        return caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ||
            caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)
    }
}
