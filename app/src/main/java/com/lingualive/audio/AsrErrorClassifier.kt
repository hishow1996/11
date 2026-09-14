package com.lingualive.audio

object AsrErrorClassifier {
    fun classify(error: Throwable): SherpaNativeFailure =
        when {
            error.message?.contains("library", true) == true -> SherpaNativeFailure.LIBRARY_MISSING
            error.message?.contains("model", true) == true -> SherpaNativeFailure.MODEL_INVALID
            else -> SherpaNativeFailure.NATIVE_INFERENCE_FAILED
        }
}
