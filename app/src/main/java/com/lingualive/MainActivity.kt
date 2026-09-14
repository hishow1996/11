package com.lingualive

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import androidx.activity.ComponentActivity
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
    private val projectionManager by lazy {
        getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme { Surface(modifier = Modifier.fillMaxSize()) { Home(::requestCapture) } }
        }
    }

    private fun requestCapture() {
        startActivityForResult(projectionManager.createScreenCaptureIntent(), REQUEST_CAPTURE)
    }

    @Deprecated("Activity Result API migration will be done with the full capture UI batch")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_CAPTURE || resultCode != Activity.RESULT_OK || data == null) return
        val metrics = resources.displayMetrics
        startService(
            Intent(this, ScreenCaptureService::class.java).apply {
                action = ScreenCaptureService.ACTION_START
                putExtra(ScreenCaptureService.EXTRA_RESULT_CODE, resultCode)
                putExtra(ScreenCaptureService.EXTRA_PROJECTION_DATA, data)
                putExtra(ScreenCaptureService.EXTRA_WIDTH, metrics.widthPixels)
                putExtra(ScreenCaptureService.EXTRA_HEIGHT, metrics.heightPixels)
                putExtra(ScreenCaptureService.EXTRA_DPI, metrics.densityDpi)
            }
        )
    }

    companion object { private const val REQUEST_CAPTURE = 7001 }
}

@Composable
private fun Home(onStart: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxSize().padding(28.dp),
        verticalArrangement = Arrangement.Center
    ) {
        Text("LinguaLive", style = MaterialTheme.typography.headlineLarge)
        Text("实时字幕翻译", style = MaterialTheme.typography.titleMedium, modifier = Modifier.padding(top = 8.dp))
        Button(onClick = onStart, modifier = Modifier.padding(top = 24.dp)) { Text("开始屏幕字幕识别") }
    }
}
