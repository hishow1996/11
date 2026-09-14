package com.lingualive.audio

class SileroVadSegmenter(
    private val minSpeechMs: Long = 250,
    private val minSilenceMs: Long = 350,
    private val sampleRate: Int = 16_000
) {
    private val frames = ArrayList<Float>()
    private var start = 0L
    private var lastSpeechEnd = 0L
    fun accept(result: SileroVadResultModel, samples: FloatArray): VadAudioSegment? {
        if (result.isSpeech) {
            if (frames.isEmpty()) start = result.startSample
            for (v in samples) frames.add(v)
            lastSpeechEnd = result.endSample
            return null
        }
        if (frames.isEmpty()) return null
        val silenceMs = (result.endSample - lastSpeechEnd) * 1000L / sampleRate
        if (silenceMs < minSilenceMs) { for(v in samples) frames.add(v); return null }
        val duration = (lastSpeechEnd - start) * 1000L / sampleRate
        val out = if (duration >= minSpeechMs) VadAudioSegment(frames.toFloatArray(), start, lastSpeechEnd) else null
        frames.clear()
        return out
    }
    fun flush(): VadAudioSegment? {
        if (frames.isEmpty()) return null
        val out = VadAudioSegment(frames.toFloatArray(), start, lastSpeechEnd)
        frames.clear()
        return out
    }
}