package com.lingualive.audio

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.media.AudioRecord
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/** Foreground audio pipeline entry: AudioPlaybackCapture -> PCM -> VAD -> ASR. */
class AudioCaptureService : Service() {
    companion object {
        const val ACTION_START = "com.lingualive.audio.START"
        const val ACTION_STOP = "com.lingualive.audio.STOP"
        const val EXTRA_PROJECTION_DATA = "projection_data"
        const val EXTRA_RESULT_CODE = "result_code"
        private const val CHANNEL = "lingualive_audio"
        private const val NOTIFICATION_ID = 1201
    }

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private var record: AudioRecord? = null
    private var readJob: Job? = null
    private var running = false

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> startForegroundCapture()
            ACTION_STOP -> stopCapture()
        }
        return START_STICKY
    }

    private fun startForegroundCapture() {
        createChannel()
        startForeground(NOTIFICATION_ID, notification())
        running = true
    }

    fun attachRecorder(audioRecord: AudioRecord, consumer: (PcmChunk) -> Unit) {
        record?.stop()
        record?.release()
        record = audioRecord
        readJob?.cancel()
        readJob = scope.launch {
            val buffer = ShortArray(16_000 / 2)
            record?.startRecording()
            while (running) {
                val count = record?.read(buffer, 0, buffer.size) ?: 0
                if (count > 0) consumer(PcmChunk(buffer.copyOf(count), 16_000, System.currentTimeMillis()))
            }
        }
    }

    private fun stopCapture() {
        running = false
        readJob?.cancel()
        readJob = null
        record?.runCatching { stop() }
        record?.release()
        record = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= 26) {
            getSystemService(NotificationManager::class.java).createNotificationChannel(
                NotificationChannel(CHANNEL, "LinguaLive 音频翻译", NotificationManager.IMPORTANCE_LOW)
            )
        }
    }

    private fun notification(): Notification = NotificationCompat.Builder(this, CHANNEL)
        .setSmallIcon(android.R.drawable.ic_btn_speak_now)
        .setContentTitle("LinguaLive 正在翻译")
        .setContentText("正在监听媒体音频")
        .setOngoing(true)
        .build()

    override fun onDestroy() {
        stopCapture()
        scope.cancel()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
