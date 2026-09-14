package com.lingualive.audio

class SileroVadPipeline(
    private val processor: SileroVadFrameProcessor,
    private val segmenter: SileroVadSegmenter,
    private val onSegment: suspend (VadAudioSegment) -> Unit
) {
    suspend fun submit(frame: VadFrameModel, probability: Float) {
        val result = processor.process(frame, probability)
        val segment = segmenter.accept(result, frame.samples)
        if (segment != null) onSegment(segment)
    }
    suspend fun flush() {
        val segment = segmenter.flush()
        if (segment != null) onSegment(segment)
    }
}