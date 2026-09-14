package com.lingualive.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.lingualive.settings.SettingsStore
import com.lingualive.subtitle.SubtitleLine
import com.lingualive.translation.ProviderConfig
import com.lingualive.translation.TranslationProviderId

@Composable
fun SettingsScreen(store: SettingsStore, onBack: () -> Unit) {
    var source by remember { mutableStateOf(store.getString("source_language", "auto")) }
    var target by remember { mutableStateOf(store.getString("target_language", "zh-CN")) }
    var provider by remember { mutableStateOf(store.getString("provider", "auto")) }
    var ocr by remember { mutableStateOf(store.getBoolean("ocr", true)) }
    var audio by remember { mutableStateOf(store.getBoolean("audio", true)) }
    var original by remember { mutableStateOf(store.getBoolean("show_original", true)) }

    Column(Modifier.fillMaxSize().padding(22.dp)) {
        TextButton(onClick = onBack) { Text("‹  返回") }
        Text("设置", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(18.dp))
        LazyColumn(verticalArrangement = Arrangement.spacedBy(14.dp)) {
            item {
                SectionCard("翻译") {
                    Text("来源语言")
                    Field(source) { source = it; store.setString("source_language", it) }
                    Text("目标语言", Modifier.padding(top = 10.dp))
                    Field(target) { target = it; store.setString("target_language", it) }
                    Text("引擎", Modifier.padding(top = 10.dp))
                    ProviderChoice(provider) { provider = it; store.setString("provider", it) }
                }
            }
            item {
                SectionCard("输入") {
                    ToggleRow("屏幕 OCR", ocr) { ocr = it; store.setBoolean("ocr", it) }
                    ToggleRow("媒体音频", audio) { audio = it; store.setBoolean("audio", it) }
                }
            }
            item {
                SectionCard("API 密钥") {
                    Text("密钥使用 Android Keystore 加密后保存在本机。", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.secondary)
                    ApiKeyField(store, TranslationProviderId.OPENAI, "OpenAI API Key", "gpt-4o-mini")
                }
            }
            item {
                SectionCard("其他引擎") {
                    Text("已接入的 API：DeepSeek、DeepL、Google、Microsoft、百度、腾讯、ModernMT。", style = MaterialTheme.typography.bodySmall)
                    Text("各服务可使用自己的凭据格式；自动模式会按顺序尝试已配置的服务。", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.secondary, modifier = Modifier.padding(top = 6.dp))
                }
            }
            item {
                SectionCard("字幕") {
                    ToggleRow("显示原文", original) { original = it; store.setBoolean("show_original", it) }
                    Text("字号、透明度、位置可在字幕样式中调整", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.secondary)
                }
            }
        }
    }
}

@Composable
private fun ApiKeyField(store: SettingsStore, id: TranslationProviderId, label: String, model: String) {
    var key by remember(id) { mutableStateOf(store.providerConfig(id).apiKey) }
    Spacer(Modifier.height(10.dp))
    OutlinedTextField(value = key, onValueChange = { key = it; store.saveProvider(id, ProviderConfig(it, "", model)) }, modifier = Modifier.fillMaxWidth(), singleLine = true, label = { Text(label) })
}

@Composable
private fun Field(v: String, c: (String) -> Unit) = OutlinedTextField(v, c, modifier = Modifier.fillMaxWidth(), singleLine = true)

@Composable
private fun ProviderChoice(v: String, c: (String) -> Unit) {
    var expanded by remember { mutableStateOf(false) }
    Box {
        OutlinedButton(onClick = { expanded = true }, modifier = Modifier.fillMaxWidth()) { Text(if (v == "auto") "自动（推荐）" else v) }
        DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
            (listOf("auto") + TranslationProviderId.entries.map { it.name }).forEach { id ->
                DropdownMenuItem(text = { Text(if (id == "auto") "自动（推荐）" else id) }, onClick = { c(id); expanded = false })
            }
        }
    }
}

@Composable
private fun ToggleRow(label: String, value: Boolean, onChange: (Boolean) -> Unit) = Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) { Text(label); Switch(checked = value, onCheckedChange = onChange) }

@Composable
fun StyleScreen(store: SettingsStore, onBack: () -> Unit) {
    var size by remember { mutableFloatStateOf(store.getFloat("overlay_font_size", 20f)) }
    var opacity by remember { mutableFloatStateOf(store.getFloat("overlay_opacity", .92f)) }
    Column(Modifier.fillMaxSize().padding(22.dp)) {
        TextButton(onClick = onBack) { Text("‹  返回") }
        Text("字幕样式", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(20.dp))
        SectionCard("预览") { Surface(Modifier.fillMaxWidth(), shape = MaterialTheme.shapes.large, color = MaterialTheme.colorScheme.inverseSurface) { Column(Modifier.padding(18.dp)) { Text("I don't think we're in Kansas anymore.", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.inverseOnSurface.copy(alpha = .7f)); Text("看来我们已经不在堪萨斯了。", fontSize = size.sp, color = MaterialTheme.colorScheme.inverseOnSurface) } } }
        Spacer(Modifier.height(20.dp))
        Text("字号 ${size.toInt()}sp")
        Slider(value = size, onValueChange = { value -> size = value; store.setFloat("overlay_font_size", value) }, valueRange = 14f..32f)
        Text("透明度 ${(opacity * 100).toInt()}%")
        Slider(value = opacity, onValueChange = { value -> opacity = value; store.setFloat("overlay_opacity", value) }, valueRange = .55f..1f)
    }
}

@Composable
fun HistoryScreen(lines: List<SubtitleLine>, onClear: () -> Unit, onBack: () -> Unit) {
    Column(Modifier.fillMaxSize().padding(22.dp)) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) { TextButton(onClick = onBack) { Text("‹  返回") }; TextButton(onClick = onClear) { Text("清空") } }
        Text("最近字幕", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(14.dp))
        LazyColumn(verticalArrangement = Arrangement.spacedBy(10.dp)) { items(lines.reversed()) { line -> SectionCard(if (line.source.name == "OCR") "屏幕" else "音频") { Text(line.original); if (line.translated.isNotBlank()) Text(line.translated, style = MaterialTheme.typography.bodyLarge, modifier = Modifier.padding(top = 5.dp)) } } }
    }
}
