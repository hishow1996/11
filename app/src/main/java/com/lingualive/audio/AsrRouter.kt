package com.lingualive.audio

/**
 * Chooses a local engine when a complete local model set is available;
 * otherwise leaves the cloud engine as the safe fallback.
 */
class AsrRouter(
    private val local: AsrEngine?,
    private val cloud: AsrEngine?
) {
    fun choose(mode: AsrMode, localAvailable: Boolean, networkAvailable: Boolean): AsrEngine? =
        when (mode) {
            AsrMode.LOCAL_FIRST -> if (localAvailable) local else if (networkAvailable) cloud else null
            AsrMode.CLOUD_ONLY -> if (networkAvailable) cloud else null
            AsrMode.AUTO -> if (localAvailable) local else if (networkAvailable) cloud else null
        }
}
