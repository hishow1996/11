package com.lingualive.audio

sealed class SileroVadSegmentEvent {
    data class Started(val sample: Long) : SileroVadSegmentEvent()
    data class Ended(val segment: VadAudioSegment) : SileroVadSegmentEvent()
}
