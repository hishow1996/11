package com.lingualive.audio

enum class LocalAsrFailure {
    RUNTIME_MISSING,
    MODEL_MISSING,
    MODEL_INVALID,
    INIT_FAILED,
    INFERENCE_FAILED,
    EMPTY_RESULT
}
