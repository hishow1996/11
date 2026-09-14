package com.lingualive.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun SubtitlePreview(original: String, translation: String, fontSizeSp: Float = 22f) {
    Card(modifier = Modifier.fillMaxWidth()) {
        Column(modifier = Modifier.padding(14.dp)) {
            Text(original, fontSize = fontSizeSp.sp)
            if (translation.isNotBlank()) {
                Text(translation, fontSize = (fontSizeSp * 0.92f).sp)
            }
        }
    }
}
