package com.lingualive.translation

import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

/** Serializes translation requests so subtitles remain in spoken order. */
class TranslationQueue {
    private val mutex = Mutex()
    suspend fun <T> submit(block: suspend () -> T): T = mutex.withLock { block() }
}
