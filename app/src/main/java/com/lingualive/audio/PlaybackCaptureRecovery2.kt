package com.lingualive.audio
class PlaybackCaptureRecovery2(private val maxRetries:Int=3){private var retries=0;fun retry():Boolean=++retries<=maxRetries;fun reset(){retries=0}}