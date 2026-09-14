package com.lingualive

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.lingualive.capture.ScreenCaptureService
import com.lingualive.ui.LinguaTheme
import com.lingualive.ui.MetricRow
import com.lingualive.ui.SectionCard
import com.lingualive.ui.StatusPill

class MainActivity : ComponentActivity() {
    private val projectionManager by lazy { getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { LinguaTheme { Surface(Modifier.fillMaxSize()) { Home(::requestCapture, ::openOverlaySettings) } } }
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
    Column(
        Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background).padding(horizontal = 22.dp, vertical = 30.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
            Column {
                Text("LinguaLive", style = MaterialTheme.typography.headlineMedium)
                Text("Live translation, quietly.", style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.secondary)
            }
            StatusPill("待机", false)
        }
        Spacer(Modifier.height(4.dp))
        SectionCard("实时翻译") {
            Text("把正在播放的内容变成自然的中文双语字幕。", style = MaterialTheme.typography.bodyLarge)
            Spacer(Modifier.height(18.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                StatusPill("OCR", true)
                StatusPill("Audio", true)
                StatusPill("中文", true)
            }
            Spacer(Modifier.height(18.dp))
            Button(
                onClick = onStart,
                modifier = Modifier.fillMaxWidth().height(52.dp),
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary)
            ) { Text("开始翻译") }
        }
        SectionCard("当前配置") {
            MetricRow(listOf("目标语言" to "中文", "字幕" to "双语", "引擎" to "自动"))
        }
        OutlinedButton(
            onClick = onOverlay,
            modifier = Modifier.fillMaxWidth().height(50.dp),
            shape = RoundedCornerShape(16.dp)
        ) { Text("设置悬浮字幕") }
        Text(
            "字幕会显示在其他应用上方。你可以随时拖动位置。",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.secondary,
            modifier = Modifier.padding(horizontal = 4.dp)
        )
    }
}
