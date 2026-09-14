package com.lingualive.audio

class SherpaOnnxVadPipeline(private val session: SherpaOnnxVadSession) {
    fun process(samples: FloatArray): Float = session.accept(samples)
    fun isSpeech(): Boolean = session.speechDetected()
    fun reset() = session.reset()
    fun close() = session.release()
}
