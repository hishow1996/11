package com.lingualive.capture

import android.graphics.Bitmap
import android.graphics.Rect
import android.media.Image
import java.nio.ByteBuffer

object BitmapFrameConverter {
    fun fromImage(image: Image): Bitmap? {
        if (image.width <= 0 || image.height <= 0 || image.planes.isEmpty()) return null
        val plane = image.planes[0]
        val buffer: ByteBuffer = plane.buffer
        val pixelStride = plane.pixelStride
        val rowStride = plane.rowStride
        val rowPadding = rowStride - pixelStride * image.width
        val paddedWidth = image.width + rowPadding / pixelStride

        val bitmap = Bitmap.createBitmap(
            paddedWidth,
            image.height,
            Bitmap.Config.ARGB_8888
        )
        buffer.rewind()
        bitmap.copyPixelsFromBuffer(buffer)

        return if (paddedWidth == image.width) {
            bitmap
        } else {
            Bitmap.createBitmap(
                bitmap,
                0,
                0,
                image.width.coerceAtMost(bitmap.width),
                image.height.coerceAtMost(bitmap.height)
            ).also { bitmap.recycle() }
        }
    }

    fun crop(bitmap: Bitmap, rect: Rect): Bitmap {
        val left = rect.left.coerceIn(0, bitmap.width - 1)
        val top = rect.top.coerceIn(0, bitmap.height - 1)
        val right = rect.right.coerceIn(left + 1, bitmap.width)
        val bottom = rect.bottom.coerceIn(top + 1, bitmap.height)
        return Bitmap.createBitmap(bitmap, left, top, right - left, bottom - top)
    }
}
