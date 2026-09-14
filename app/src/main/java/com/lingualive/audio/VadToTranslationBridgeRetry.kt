package com.lingualive.audio
import com.lingualive.translation.TranslationInput
class VadToTranslationBridgeRetry(private val onInput:suspend(TranslationInput)->Unit){suspend fun submit(asr:AsrDecodeResult,segment:VadAudioSegment){val r=asr.result?:return;val t=r.text.trim();if(t.isNotEmpty())onInput(TranslationInput(t,r.language,segment.startSample*1000L/16000L,segment.endSample*1000L/16000L))}}