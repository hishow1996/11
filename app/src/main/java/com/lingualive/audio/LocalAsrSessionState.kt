package com.lingualive.audio

enum class LocalAsrSessionState {
    IDLE, INITIALIZING, READY, LISTENING, RECOGNIZING, FALLBACK, ERROR, STOPPED
}
