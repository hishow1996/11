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
    private var job: Job? = null

    fun submit(bitmap: Bitmap) {
        val snapshot = bitmap.copy(Bitmap.Config.ARGB_8888, false)
        job?.cancel()
        job = scope.launch {
            try {
                val result = recognizer.recognize(snapshot)
                if (deduplicator.accept(result.text)) _latest.value = result
            } finally {
                snapshot.recycle()
            }
        }
    }

    fun close() {
        job?.cancel()
        recognizer.close()
    }
}
