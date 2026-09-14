package com.lingualive.subtitle

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.IBinder

class SubtitleOverlayService : Service() {
    companion object {
        const val CHANNEL_ID = "subtitle_overlay"
        const val ACTION_SHOW = "com.lingualive.subtitle.SHOW"
        const val ACTION_HIDE = "com.lingualive.subtitle.HIDE"
    }

    override fun onCreate() {
        super.onCreate()
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Live subtitles",
                NotificationManager.IMPORTANCE_LOW
            )
        )
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_SHOW -> SubtitleOverlayStateHolder.state.show()
            ACTION_HIDE -> SubtitleOverlayStateHolder.state.hide()
        }
        startForeground(1002, notification())
        return START_STICKY
    }

    private fun notification(): Notification =
        Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("LinguaLive")
            .setContentText("实时字幕正在运行")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .build()

    override fun onBind(intent: Intent?): IBinder? = null
}

object SubtitleOverlayStateHolder {
    val state = SubtitleOverlayState()
}
