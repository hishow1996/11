package com.lingualive.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Slider
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.lingualive.settings.SettingsStore
import com.lingualive.translation.TranslationProviderId

@Composable
fun SettingsScreen(store: SettingsStore, onBack: () -> Unit) {
    var source by remember { mutableStateOf(store.getString("source_language", "auto")) }
    var target by remember { mutableStateOf(store.getString("target_language", "zh-CN")) }
    var apiKey by remember { mutableStateOf(store.providerConfig(TranslationProviderId.OPENAI).apiKey) }
    var baseUrl by remember { mutableStateOf(store.providerConfig(TranslationProviderId.OPENAI).baseUrl) }
    var audio by remember { mutableStateOf(store.getBoolean("audio", true)) }
    var fontSize by remember { mutableStateOf(store.getFloat("overlay_font_size", 22f)) }
    Column(Modifier.fillMaxSize().padding(20.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
        Text("翻译设置", style = MaterialTheme.typography.headlineMedium)
        OutlinedTextField(source, { source = it; store.setString("source_language", it) }, Modifier.fillMaxWidth(), label = { Text("源语言（auto / zh / en / ja…）") })
        OutlinedTextField(target, { target = it; store.setString("target_language", it) }, Modifier.fillMaxWidth(), label = { Text("目标语言") })
        OutlinedTextField(apiKey, { apiKey = it; store.saveProvider(TranslationProviderId.OPENAI, store.providerConfig(TranslationProviderId.OPENAI).copy(apiKey = it)) }, Modifier.fillMaxWidth(), label = { Text("ASR / 翻译 API Key") })
        OutlinedTextField(baseUrl, { baseUrl = it; store.saveProvider(TranslationProviderId.OPENAI, store.providerConfig(TranslationProviderId.OPENAI).copy(baseUrl = it)) }, Modifier.fillMaxWidth(), label = { Text("OpenAI 兼容 API 地址（可选）") })
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
            Column { Text("外放声音实时翻译"); Text("Android 10+ 捕获系统媒体音频", style = MaterialTheme.typography.bodySmall) }
            Switch(checked = audio, onCheckedChange = { audio = it; store.setBoolean("audio", it) })
        }
        Text("字幕字号：${fontSize.toInt()}sp")
        Slider(value = fontSize, onValueChange = { fontSize = it; store.setFloat("overlay_font_size", it) }, valueRange = 12f..64f)
        Text("Android 9：保留安装与 OCR/麦克风兼容；系统外放捕获需 Android 10+。", style = MaterialTheme.typography.bodySmall)
        Text("返回", modifier = Modifier.align(Alignment.End), color = MaterialTheme.colorScheme.primary)
    }
}
