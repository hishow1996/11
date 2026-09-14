package com.lingualive

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import android.provider.Settings
import android.net.Uri
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.lingualive.capture.ScreenCaptureService

class MainActivity : ComponentActivity() {
    private val projectionManager by lazy { getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { MaterialTheme { Surface(Modifier.fillMaxSize()) { Home(::requestCapture, ::openOverlaySettings) } } }
    }

    private fun requestCapture() = captureLauncher.launch(projectionManager.createScreenCaptureIntent())

    private val captureLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        if (result.resultCode != Activity.RESULT_OK || result.data == null) return@registerForActivityResult
        val metrics = resources.displayMetrics
        startService(Intent(this, ScreenCaptureService::class.java).apply {
            action = ScreenCaptureService.ACTION_START
            putExtra(ScreenCaptureService.EXTRA_RESULT_CODE, result.resultCode)
            putExtra(ScreenCaptureService.EXTRA_PROJECTION_DATA, result.data)
            putExtra(ScreenCaptureService.EXTRA_WIDTH, metrics.widthPixels)
            putExtra(ScreenCaptureService.EXTRA_HEIGHT, metrics.heightPixels)
            putExtra(ScreenCaptureService.EXTRA_DPI, metrics.densityDpi)
        })
    }

    private fun openOverlaySettings() {
        if (!Settings.canDrawOverlays(this)) startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")))
    }
}

@Composable
private fun Home(onStart: () -> Unit, onOverlay: () -> Unit) {
    Column(Modifier.fillMaxSize().padding(28.dp), verticalArrangement = Arrangement.Center) {
        Text("LinguaLive", style = MaterialTheme.typography.headlineLarge)
        Text("实时直播翻译 · OCR + 多引擎", style = MaterialTheme.typography.titleMedium, modifier = Modifier.padding(top = 8.dp))
        Button(onClick = onStart, modifier = Modifier.padding(top = 24.dp)) { Text("开始屏幕字幕识别") }
        Button(onClick = onOverlay, modifier = Modifier.padding(top = 12.dp)) { Text("开启悬浮字幕权限") }
    }
}
