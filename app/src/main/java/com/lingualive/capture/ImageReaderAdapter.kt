package com.lingualive.capture

import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.os.Handler
import android.os.Looper
import java.util.concurrent.atomic.AtomicBoolean

class ImageReaderAdapter(
    private val projection: MediaProjection,
    private val config: CaptureConfig,
    private val onFrame: (Bitmap) -> Unit
) : AutoCloseable {
    private val closed = AtomicBoolean(false)
    private val handler = Handler(Looper.getMainLooper())
    private val reader = ImageReader.newInstance(
        config.width,
        config.height,
        PixelFormat.RGBA_8888,
        2
    )
    private var display: VirtualDisplay? = null
    private var lastFrameAt = 0L

    init {
        reader.setOnImageAvailableListener({ source ->
            if (closed.get()) return@setOnImageAvailableListener
            val now = android.os.SystemClock.elapsedRealtime()
            val minInterval = if (config.maxFps <= 0) 0L else 1000L / config.maxFps
            val image = source.acquireLatestImage() ?: return@setOnImageAvailableListener
            try {
                if (now - lastFrameAt >= minInterval) {
                    lastFrameAt = now
                    BitmapFrameConverter.fromImage(image)?.let(onFrame)
                }
            } finally {
                image.close()
            }
        }, handler)
    }

    fun start() {
        check(!closed.get()) { "Capture adapter is closed" }
        if (display != null) return
        display = projection.createVirtualDisplay(
            "LinguaLive-OCR",
            config.width,
            config.height,
            config.dpi,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            reader.surface,
            null,
            handler
        )
    }

    override fun close() {
        if (!closed.compareAndSet(false, true)) return
        display?.release()
        display = null
        reader.close()
    }
}
