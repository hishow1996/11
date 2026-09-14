package com.lingualive.audio
class AsrLatencyTrackerRetry{private var started=0L;fun start(now:Long){started=now};fun finish(now:Long)=if(started==0L)0L else now-started}