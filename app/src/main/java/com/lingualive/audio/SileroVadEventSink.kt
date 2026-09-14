package com.lingualive.audio

fun interface SileroVadEventSink { suspend fun emit(event: SileroVadSegmentEvent) }
