package com.lingualive.translation

import android.content.Context
import android.content.Intent
import com.lingualive.ocr.OcrResult
import com.lingualive.overlay.SubtitleOverlayService
import com.lingualive.subtitle.SubtitleLine
import com.lingualive.subtitle.SubtitleRepository
import com.lingualive.subtitle.SubtitleSource
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

class LiveTranslationCoordinator(
    private val context: Context,
    private val repository: SubtitleRepository = SubtitleRepository(),
    private val engine: TranslationEngine = DefaultTranslationEngine.create(),
    private val configs: Map<TranslationProviderId, ProviderConfig> = emptyMap(),
    private val providerOrder: List<TranslationProviderId> = listOf(
        TranslationProviderId.OPENAI,
        TranslationProviderId.DEEPSEEK,
        TranslationProviderId.DEEPL,
        TranslationProviderId.GOOGLE,
        TranslationProviderId.LOCAL
    )
) {
    private val scope = CoroutineScope(Dispatchers.Default)
    private var job: Job? = null
    private var lastText = ""

    fun submitOcr(result: OcrResult) {
        val text = result.text.trim()
        if (text.isEmpty() || text == lastText) return
        lastText = text
        job?.cancel()
        job = scope.launch {
            var translated = ""
            try {
                translated = engine.translate(
                    TranslationRequest(text = text), providerOrder, configs
                ).text
            } catch (_: Throwable) {
                // Keep the original visible even when no provider is configured or the network fails.
            }
            repository.upsert(
                SubtitleLine(
                    id = result.timestampMs,
                    original = text,
                    translated = translated,
                    startTimeMs = result.timestampMs,
                    endTimeMs = result.timestampMs + 3500L,
                    source = SubtitleSource.OCR
                )
            )
            publishOverlay(text, translated)
        }
    }

    private fun publishOverlay(original: String, translated: String) {
        context.startService(Intent(context, SubtitleOverlayService::class.java).apply {
            action = SubtitleOverlayService.ACTION_SHOW
            putExtra(SubtitleOverlayService.EXTRA_ORIGINAL, original)
            putExtra(SubtitleOverlayService.EXTRA_TRANSLATED, translated)
        })
    }

    fun clear() = repository.clear()
    fun close() { job?.cancel() }
}
