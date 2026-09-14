package com.lingualive.ocr

import android.graphics.Bitmap
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class LiveOcrPipeline(
    private val recognizer: MlKitSubtitleRecognizer = MlKitSubtitleRecognizer(),
    private val deduplicator: OcrDeduplicator = OcrDeduplicator()
) {
    private val _latest = MutableStateFlow<OcrResult?>(null)
    val latest: StateFlow<OcrResult?> = _latest
    private val scope = CoroutineScope(Dispatchers.Default)
    private val lock = Any()
    private var job: Job? = null
    private var pending: Bitmap? = null
    private var closed = false

    fun submit(bitmap: Bitmap) {
        val snapshot = bitmap.copy(Bitmap.Config.ARGB_8888, false)
        var shouldStart = false
        synchronized(lock) {
            if (closed) {
                snapshot.recycle()
                return
            }
            pending?.recycle()
            pending = snapshot
            if (job?.isActive != true) shouldStart = true
        }
        if (shouldStart) startWorker()
    }

    private fun startWorker() {
        synchronized(lock) {
            if (closed || job?.isActive == true) return
            job = scope.launch {
                while (true) {
                    val snapshot = synchronized(lock) {
                        val next = pending
                        pending = null
                        next
                    }

                    if (snapshot == null) {
                        synchronized(lock) { job = null }
                        return@launch
                    }

                    try {
                        val result = recognizer.recognize(snapshot)
                        if (deduplicator.accept(result.text)) _latest.value = result
                    } finally {
                        snapshot.recycle()
                    }
                }
            }
        }
    }

    fun close() {
        val pendingToRecycle = synchronized(lock) {
            closed = true
            val next = pending
            pending = null
            job?.cancel()
            job = null
            next
        }
        pendingToRecycle?.recycle()
        recognizer.close()
    }
}
