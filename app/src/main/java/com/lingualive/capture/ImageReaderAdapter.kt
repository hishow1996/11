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
    private val reader = ImageReader.newInstance(config.width, config.height, PixelFormat.RGBA_8888, 2)
    private var display: VirtualDisplay? = null
    private var lastFrameAt = 0L

    init {
        reader.setOnImageAvailableListener({ source ->
            if (closed.get()) return@setOnImageAvailableListener
            val now = android.os.SystemClock.elapsedRealtime()
            val minInterval = if (config.ocrIntervalMs > 0) config.ocrIntervalMs else if (config.maxFps > 0) 1000L / config.maxFps else 0L
            val image = source.acquireLatestImage() ?: return@setOnImageAvailableListener
            var frame: Bitmap? = null
            try {
                if (now - lastFrameAt >= minInterval) {
                    lastFrameAt = now
                    frame = BitmapFrameConverter.fromImage(image)
                    if (frame != null) {
                        val r = config.subtitleRegion.toPixels(frame.width, frame.height)
                        val crop = Bitmap.createBitmap(frame, r.left, r.top, r.right - r.left, r.bottom - r.top)
                        onFrame(crop)
                    }
                }
            } finally {
                frame?.recycle()
                image.close()
            }
        }, handler)
    }

    fun start() {
        check(!closed.get()) { "Capture adapter is closed" }
        if (display != null) return
        display = projection.createVirtualDisplay("LinguaLive-OCR", config.width, config.height, config.dpi,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR, reader.surface, null, handler)
    }

    override fun close() {
        if (!closed.compareAndSet(false, true)) return
        display?.release(); display = null; reader.close()
    }
}
