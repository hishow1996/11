package com.lingualive.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun LiveTranslateScreen(viewModel: LiveTranslateViewModel) {
    val uiState by viewModel.uiState.collectAsState()
    Column(
        modifier = Modifier.fillMaxSize().padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text("实时翻译", style = MaterialTheme.typography.headlineMedium)
        Text(if (uiState.running) "正在监听直播声音" else "尚未开始")
        Button(onClick = { if (uiState.running) viewModel.stop() else viewModel.start() }) {
            Text(if (uiState.running) "停止翻译" else "开始翻译")
        }
        Text("字幕字号：" + uiState.fontSizeSp.toInt() + "sp")
        Slider(value = uiState.fontSizeSp, onValueChange = viewModel::setFontSize, valueRange = 12f..64f)
        Text("背景透明度：" + (uiState.backgroundAlpha * 100).toInt() + "%")
        Slider(value = uiState.backgroundAlpha, onValueChange = viewModel::setBackgroundAlpha, valueRange = 0f..1f)
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text("显示原文")
            Switch(checked = uiState.showOriginal, onCheckedChange = {
                viewModel.setSubtitleOptions(it, uiState.showTranslation)
            })
        }
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text("显示中文")
            Switch(checked = uiState.showTranslation, onCheckedChange = {
                viewModel.setSubtitleOptions(uiState.showOriginal, it)
            })
        }
    }
}