package com.lingualive.audio

data class VadFrameModel(
    val samples: FloatArray,
    val startSample: Long,
    val endSample: Long
)