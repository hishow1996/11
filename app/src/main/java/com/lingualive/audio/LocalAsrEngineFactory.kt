package com.lingualive.audio

import java.io.File

object LocalAsrEngineFactory {
    fun create(root: File): SenseVoiceAsrEngine? {
        val readiness = LocalAsrReadinessChecker.check(root)
        if (!readiness.ready) return null
        val config = SenseVoiceConfigFactory.create(
            root,
            LocalAsrDeviceProfileProvider.current().recommendedThreads
        ) ?: return null
        return SenseVoiceAsrEngine(root, config)
    }
}
