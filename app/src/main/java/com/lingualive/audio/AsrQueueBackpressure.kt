package com.lingualive.audio
class AsrQueueBackpressure(private val maxPending:Int=2){fun shouldDrop(pending:Int)=pending>=maxPending}