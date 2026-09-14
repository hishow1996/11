package com.lingualive.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun SettingsScreen() {
    var source by remember { mutableStateOf("auto") }
    var target by remember { mutableStateOf("zh-CN") }
    var apiKey by remember { mutableStateOf("") }
    var fontSize by remember { mutableStateOf(22f) }
    Column(
        modifier = Modifier.fillMaxSize().padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        Text("翻译设置", style = MaterialTheme.typography.headlineMedium)
        OutlinedTextField(value = source, onValueChange = { source = it }, label = { Text("源语言") })
        OutlinedTextField(value = target, onValueChange = { target = it }, label = { Text("目标语言") })
        OutlinedTextField(value = apiKey, onValueChange = { apiKey = it }, label = { Text("API Key") }, singleLine = true)
        Text("字幕字号：" + fontSize.toInt() + "sp")
        Slider(value = fontSize, onValueChange = { fontSize = it }, valueRange = 12f..64f)
    }
}