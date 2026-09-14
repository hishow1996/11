package com.lingualive.translation

import android.content.Context
import com.lingualive.subtitle.SubtitleRepository

object LiveTranslationRuntime {
    @Volatile private var coordinator: LiveTranslationCoordinator? = null

    @Synchronized
    fun get(context: Context): LiveTranslationCoordinator {
        return coordinator ?: LiveTranslationCoordinator(
            context.applicationContext,
            SubtitleRepository()
        ).also { coordinator = it }
    }

    @Synchronized
    fun reset() {
        coordinator?.close()
        coordinator = null
    }
}
