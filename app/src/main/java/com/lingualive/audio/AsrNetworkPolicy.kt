package com.lingualive.audio

class AsrNetworkPolicy {
    @Volatile var networkAvailable: Boolean = true

    fun choose(local: AsrEngine?, cloud: AsrEngine?): AsrEngine? {
        if (!networkAvailable) return local
        return local ?: cloud
    }
}
