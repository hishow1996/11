package com.lingualive.audio
class SileroVadEngineFixed(private val inference:SileroVadInferencePort,private val processor:SileroVadFrameProcessor=SileroVadFrameProcessor(),private val segmenter:SileroVadSegmenter=SileroVadSegmenter()){
 suspend fun process(frame:VadFrameModel,onSegment:suspend(VadAudioSegment)->Unit){val p=inference.probability(frame.samples).coerceIn(0f,1f);val r=processor.process(frame,p);segmenter.accept(r,frame.samples)?.let{onSegment(it)}}
 suspend fun flush(onSegment:suspend(VadAudioSegment)->Unit){segmenter.flush()?.let{onSegment(it)}}
 fun reset(){inference.reset();processor.reset()}
}