package com.lingualive.audio

object SileroVadSegmentEventMapper {
    fun ended(segment: VadAudioSegment): SileroVadSegmentEvent = SileroVadSegmentEvent.Ended(segment)
}
