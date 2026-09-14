package com.lingualive.translation

import android.content.Context
import android.content.Intent
import com.lingualive.ocr.OcrResult
import com.lingualive.overlay.SubtitleOverlayService
import com.lingualive.settings.SettingsStore
import com.lingualive.subtitle.SubtitleLine
import com.lingualive.subtitle.SubtitleRepository
import com.lingualive.subtitle.SubtitleSource
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class LiveTranslationCoordinator(private val context: Context, private val repository: SubtitleRepository = SubtitleRepository(), private val engine: TranslationEngine = DefaultTranslationEngine.create()) {
    private val settings = SettingsStore(context)
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private var job: Job? = null
    private var lastText = ""
    private val _state = MutableStateFlow(TranslationRuntimeState())
    val state: StateFlow<TranslationRuntimeState> = _state.asStateFlow()
    val lines = repository.lines
    fun submitOcr(result: OcrResult) = submit(result.text, result.timestampMs, SubtitleSource.OCR)
    fun submitSpeech(text: String, timestampMs: Long = System.currentTimeMillis()) = submit(text, timestampMs, SubtitleSource.SPEECH)
    private fun submit(raw: String, timestampMs: Long, source: SubtitleSource) {
        val text = raw.trim()
        if (text.isEmpty() || text == lastText) return
        lastText = text; job?.cancel()
        job = scope.launch {
            val started = System.currentTimeMillis(); _state.value = _state.value.copy(translating = true, lastSource = source)
            var translated = ""; var provider = "自动"
            try {
                val order = providerOrder(settings.getString("provider", "auto"))
                val configs = order.associateWith { settings.providerConfig(it) }
                val response = engine.translate(TranslationRequest(text, settings.getString("source_language", "auto"), settings.getString("target_language", "zh-CN")), order, configs)
                translated = response.text; provider = response.provider.name
            } catch (_: Throwable) { }
            repository.upsert(SubtitleLine(timestampMs, text, translated, timestampMs, timestampMs + 3500, source))
            publishOverlay(text, translated)
            _state.value = _state.value.copy(translating = false, lastProvider = provider, latencyMs = System.currentTimeMillis() - started, lastText = text)
        }
    }
    private fun providerOrder(selected: String): List<TranslationProviderId> = if (selected == "auto") listOf(TranslationProviderId.OPENAI, TranslationProviderId.DEEPSEEK, TranslationProviderId.DEEPL, TranslationProviderId.GOOGLE, TranslationProviderId.LOCAL) else runCatching { listOf(TranslationProviderId.valueOf(selected)) }.getOrDefault(emptyList())
    private fun publishOverlay(original: String, translated: String) {
        context.startService(Intent(context, SubtitleOverlayService::class.java).apply {
            action = SubtitleOverlayService.ACTION_SHOW
            putExtra(SubtitleOverlayService.EXTRA_ORIGINAL, original)
            putExtra(SubtitleOverlayService.EXTRA_TRANSLATED, translated)
            putExtra(SubtitleOverlayService.EXTRA_FONT_SIZE, settings.getFloat("overlay_font_size", 20f))
            putExtra(SubtitleOverlayService.EXTRA_OPACITY, settings.getFloat("overlay_opacity", .92f))
            putExtra(SubtitleOverlayService.EXTRA_SHOW_ORIGINAL, settings.getBoolean("show_original", true))
        })
    }
    fun clear() = repository.clear()
    fun close() { job?.cancel(); scope.cancel() }
}

data class TranslationRuntimeState(val translating: Boolean = false, val lastText: String = "", val lastProvider: String = "自动", val latencyMs: Long = 0, val lastSource: SubtitleSource = SubtitleSource.OCR)