package com.lingualive.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun HomeScreen(onStart: () -> Unit, onSettings: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(18.dp)
    ) {
        Text("LinguaLive", style = MaterialTheme.typography.headlineLarge)
        Text("实时听译你的直播、视频和游戏声音")
        Button(onClick = onStart, modifier = Modifier.fillMaxWidth()) {
            Text("开始实时翻译")
        }
        Button(onClick = onSettings, modifier = Modifier.fillMaxWidth()) {
            Text("设置")
        }
    }
}
