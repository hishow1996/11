package com.lingualive.overlay

import android.app.Service
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.view.*
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.math.roundToInt

class SubtitleOverlayService : Service() {
    companion object {
        const val ACTION_SHOW = "com.lingualive.overlay.SHOW"; const val ACTION_HIDE = "com.lingualive.overlay.HIDE"
        const val EXTRA_ORIGINAL = "original"; const val EXTRA_TRANSLATED = "translated"
        const val EXTRA_FONT_SIZE = "font_size"; const val EXTRA_OPACITY = "opacity"; const val EXTRA_SHOW_ORIGINAL = "show_original"
    }
    private var wm: WindowManager? = null; private var root: LinearLayout? = null; private var params: WindowManager.LayoutParams? = null
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_HIDE -> hide()
            ACTION_SHOW -> show(intent)
        }; return START_STICKY
    }
    private fun show(intent: Intent) {
        if (!Settings.canDrawOverlays(this)) return
        if (root == null) createWindow()
        val original = root?.findViewWithTag<TextView>("original")
        original?.text = intent.getStringExtra(EXTRA_ORIGINAL).orEmpty()
        original?.visibility = if (intent.getBooleanExtra(EXTRA_SHOW_ORIGINAL, true) && original.text.isNotBlank()) View.VISIBLE else View.GONE
        root?.findViewWithTag<TextView>("translated")?.apply { text = intent.getStringExtra(EXTRA_TRANSLATED).orEmpty().ifBlank { "翻译暂不可用" }; textSize = intent.getFloatExtra(EXTRA_FONT_SIZE, 20f).coerceIn(14f, 32f) }
        root?.alpha = intent.getFloatExtra(EXTRA_OPACITY, .92f).coerceIn(.55f, 1f); root?.visibility = View.VISIBLE
    }
    private fun createWindow() {
        wm = getSystemService(WINDOW_SERVICE) as WindowManager
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL; setPadding(28, 15, 28, 16); elevation = 10f
            background = GradientDrawable().apply { setColor(Color.argb(238, 24, 26, 25)); cornerRadius = 22f; setStroke(1, Color.argb(35, 255,255,255)) }
        }
        val original = TextView(this).apply { tag="original"; setTextColor(Color.argb(180,255,255,255)); textSize=14f; gravity=Gravity.CENTER; maxLines=2 }
        val translated = TextView(this).apply { tag="translated"; setTextColor(Color.WHITE); textSize=20f; gravity=Gravity.CENTER; typeface=Typeface.DEFAULT_BOLD; maxLines=3; includeFontPadding=false }
        container.addView(original, LinearLayout.LayoutParams(-1,-2)); container.addView(translated, LinearLayout.LayoutParams(-1,-2).apply { topMargin=4 })
        container.setOnTouchListener(DragTouchListener())
        val type = if (Build.VERSION.SDK_INT >= 26) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY else WindowManager.LayoutParams.TYPE_PHONE
        val p = WindowManager.LayoutParams(-1,-2,type,WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,PixelFormat.TRANSLUCENT).apply { gravity=Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL; y=88 }
        wm?.addView(container,p); root=container; params=p
    }
    private inner class DragTouchListener: View.OnTouchListener {
        private var downX=0f; private var downY=0f; private var startX=0; private var startY=0
        override fun onTouch(v:View,e:MotionEvent):Boolean { val p=params?:return false; when(e.actionMasked){MotionEvent.ACTION_DOWN->{downX=e.rawX;downY=e.rawY;startX=p.x;startY=p.y;return true};MotionEvent.ACTION_MOVE->{p.x=startX+(e.rawX-downX).roundToInt();p.y=startY-(e.rawY-downY).roundToInt();wm?.updateViewLayout(root,p);return true}};return true }
    }
    private fun hide(){root?.visibility=View.GONE}
    override fun onDestroy(){root?.let{wm?.removeView(it)};root=null;wm=null;super.onDestroy()}
    override fun onBind(intent:Intent?):IBinder?=null
}