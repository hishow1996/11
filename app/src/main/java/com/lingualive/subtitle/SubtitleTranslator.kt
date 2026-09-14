package com.lingualive.subtitle

import com.lingualive.ocr.OcrResult
import com.lingualive.translation.ProviderConfig
import com.lingualive.translation.TranslationEngine
import com.lingualive.translation.TranslationProviderId
import com.lingualive.translation.TranslationRequest
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class SubtitleTranslator(
    private val engine: TranslationEngine,
    private val configs: Map<TranslationProviderId, ProviderConfig>,
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.Default)
) {
    private val _subtitle = MutableStateFlow<SubtitleBox?>(null)
    val subtitle: StateFlow<SubtitleBox?> = _subtitle
    private var job: Job? = null
    private var lastSource = ""

    fun submit(result: OcrResult) {
        val source = result.text.trim()
        if (source.length < 2 || source == lastSource) return
        lastSource = source
        job?.cancel()
        job = scope.launch {
            try {
                val translated = engine.translate(
                    TranslationRequest(source),
                    listOf(TranslationProviderId.DEEPSEEK, TranslationProviderId.OPENAI, TranslationProviderId.DEEPL, TranslationProviderId.GOOGLE),
                    configs
                ).text
                val b = result.bounds
                _subtitle.value = SubtitleBox(source, translated, b?.left ?: 0, b?.top ?: 0, b?.right ?: 0, b?.bottom ?: 0, result.timestampMs)
            } catch (_: Throwable) {
                _subtitle.value = SubtitleBox(source, "", timestampMs = result.timestampMs)
            }
        }
    }

    fun close() { job?.cancel() }
}
