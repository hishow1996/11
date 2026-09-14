package com.lingualive.audio

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

object LocalAsrWarmup {
    suspend fun check(root: File): LocalAsrReadiness =
        withContext(Dispatchers.Default) {
            LocalAsrReadinessChecker.check(root)
        }
}
