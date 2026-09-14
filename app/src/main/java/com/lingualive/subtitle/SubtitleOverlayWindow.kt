package com.lingualive.subtitle

import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.view.Gravity
import android.view.WindowManager
import android.widget.TextView

class SubtitleOverlayWindow(private val context: Context) {
    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private var view: TextView? = null

    fun show(text: String, style: SubtitleStyle = SubtitleStyle()) {
        if (view == null) {
            view = TextView(context).apply {
                setPadding(24, 12, 24, 12)
                gravity = Gravity.CENTER
            }
            val type = if (Build.VERSION.SDK_INT >= 26) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                WindowManager.LayoutParams.TYPE_PHONE
            }
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                type,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                PixelFormat.TRANSLUCENT
            )
            params.gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            params.y = 80
            windowManager.addView(view, params)
        }
        view?.apply {
            this.text = text
            textSize = style.fontSizeSp
            alpha = 1f
        }
    }

    fun hide() {
        view?.let {
            windowManager.removeView(it)
            view = null
        }
    }
}
