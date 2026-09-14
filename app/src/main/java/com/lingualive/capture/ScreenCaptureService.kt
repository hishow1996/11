package com.lingualive.capture

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.projection.MediaProjection
import android.os.Build
import android.os.IBinder
import com.lingualive.ocr.OcrResult
import com.lingualive.translation.LiveTranslationRuntime
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class ScreenCaptureService : Service() {
    companion object {
        const val ACTION_START = "com.lingualive.capture.START"
        const val ACTION_STOP = "com.lingualive.capture.STOP"
        const val EXTRA_RESULT_CODE = "result_code"
        const val EXTRA_PROJECTION_DATA = "projection_data"
        const val EXTRA_WIDTH = "width"
        const val EXTRA_HEIGHT = "height"
        const val EXTRA_DPI = "dpi"
        const val NOTIFICATION_CHANNEL = "screen_capture"
        const val NOTIFICATION_ID = 2001
    }

    private val serviceScope = CoroutineScope(Dispatchers.Default)
    private var ocrJob: Job? = null
    private var adapter: ImageReaderAdapter? = null
    private var projection: MediaProjection? = null
    private var ocrBridge: CaptureOcrBridge? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> stopCapture()
            ACTION_START -> startCapture(intent)
        }
        return START_NOT_STICKY
    }

    private fun startCapture(intent: Intent) {
        val resultCode = intent.getIntExtra(EXTRA_RESULT_CODE, -1)
        val data = intent.parcelableIntent(EXTRA_PROJECTION_DATA) ?: run { stopSelf(); return }
        val width = intent.getIntExtra(EXTRA_WIDTH, 1080)
        val height = intent.getIntExtra(EXTRA_HEIGHT, 1920)
        val dpi = intent.getIntExtra(EXTRA_DPI, resources.displayMetrics.densityDpi)

        startForegroundCompat()
        stopCaptureResources()
        projection = MediaProjectionController(this).obtainProjection(resultCode, data)
        val config = CaptureConfig(width = width, height = height, dpi = dpi)
        val bridge = CaptureOcrBridge(config)
        ocrBridge = bridge
        ocrJob = serviceScope.launch {
            bridge.latest.collectLatest { result: OcrResult? ->
                if (result != null) LiveTranslationRuntime.get(this@ScreenCaptureService).submitOcr(result)
            }
        }
        adapter = ImageReaderAdapter(projection!!, config) { bitmap ->
            bridge.onFrame(bitmap)
            bitmap.recycle()
        }.also { it.start() }
    }

    private fun stopCapture() {
        stopCaptureResources()
        stopSelf()
    }

    private fun stopCaptureResources() {
        ocrJob?.cancel()
        ocrJob = null
        adapter?.close()
        adapter = null
        projection?.stop()
        projection = null
        ocrBridge?.close()
        ocrBridge = null
    }

    private fun startForegroundCompat() {
        val notification = Notification.Builder(this, NOTIFICATION_CHANNEL)
            .setContentTitle("LinguaLive")
            .setContentText("正在实时识别屏幕字幕")
            .setSmallIcon(android.R.drawable.ic_menu_view)
            .setOngoing(true)
            .build()
        if (Build.VERSION.SDK_INT >= 29) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= 26) {
            getSystemService(NotificationManager::class.java).createNotificationChannel(
                NotificationChannel(NOTIFICATION_CHANNEL, "实时字幕采集", NotificationManager.IMPORTANCE_LOW)
            )
        }
    }

    override fun onDestroy() {
        stopCaptureResources()
        LiveTranslationRuntime.reset()
        serviceScope.cancel()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}

@Suppress("DEPRECATION")
private fun Intent.parcelableIntent(key: String): Intent? =
    if (Build.VERSION.SDK_INT >= 33) getParcelableExtra(key, Intent::class.java) else getParcelableExtra(key)
