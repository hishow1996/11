package com.lingualive.overlay

import android.app.Service
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import android.graphics.Typeface

class SubtitleOverlayService : Service() {
    companion object {
        const val ACTION_SHOW = "com.lingualive.overlay.SHOW"
        const val ACTION_HIDE = "com.lingualive.overlay.HIDE"
        const val EXTRA_ORIGINAL = "original"
        const val EXTRA_TRANSLATED = "translated"
    }

    private var wm: WindowManager? = null
    private var root: LinearLayout? = null
    private var params: WindowManager.LayoutParams? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_HIDE -> hide()
            ACTION_SHOW -> show(intent.getStringExtra(EXTRA_ORIGINAL).orEmpty(), intent.getStringExtra(EXTRA_TRANSLATED).orEmpty())
        }
        return START_STICKY
    }

    private fun show(original: String, translated: String) {
        if (!Settings.canDrawOverlays(this)) return
        if (root == null) createWindow()
        root?.findViewWithTag<TextView>("original")?.apply { text = original; visibility = if (original.isBlank()) View.GONE else View.VISIBLE }
        root?.findViewWithTag<TextView>("translated")?.text = translated.ifBlank { "翻译暂不可用" }
        root?.visibility = View.VISIBLE
    }

    private fun createWindow() {
        wm = getSystemService(WINDOW_SERVICE) as WindowManager
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(24, 13, 24, 14)
            setBackgroundColor(Color.argb(232, 18, 20, 19))
            elevation = 12f
        }
        val original = TextView(this).apply {
            tag = "original"
            setTextColor(Color.argb(190, 255, 255, 255))
            textSize = 14f
            gravity = Gravity.CENTER
            maxLines = 2
        }
        val translated = TextView(this).apply {
            tag = "translated"
            setTextColor(Color.WHITE)
            textSize = 20f
            gravity = Gravity.CENTER
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            maxLines = 3
        }
        container.addView(original, LinearLayout.LayoutParams(-1, -2))
        container.addView(translated, LinearLayout.LayoutParams(-1, -2))
        container.setOnTouchListener(DragTouchListener())
        val type = if (Build.VERSION.SDK_INT >= 26) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY else WindowManager.LayoutParams.TYPE_PHONE
        val p = WindowManager.LayoutParams(-1, -2, type, WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS, PixelFormat.TRANSLUCENT).apply {
            gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            y = 88
        }
        wm?.addView(container, p)
        root = container
        params = p
    }

    private inner class DragTouchListener : View.OnTouchListener {
        private var downX = 0f; private var downY = 0f; private var startX = 0; private var startY = 0
        override fun onTouch(v: View, event: MotionEvent): Boolean {
            val p = params ?: return false
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> { downX = event.rawX; downY = event.rawY; startX = p.x; startY = p.y; return true }
                MotionEvent.ACTION_MOVE -> { p.x = startX + (event.rawX - downX).toInt(); p.y = startY - (event.rawY - downY).toInt(); wm?.updateViewLayout(root, p); return true }
            }
            return true
        }
    }

    private fun hide() { root?.visibility = View.GONE }
    override fun onDestroy() { root?.let { wm?.removeView(it) }; root = null; wm = null; super.onDestroy() }
    override fun onBind(intent: Intent?): IBinder? = null
}
