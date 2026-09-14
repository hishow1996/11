package com.lingualive.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun EngineSelectionScreen(
    state: EngineSelectionState,
    onSelect: (String) -> Unit
) {
    Column(
        modifier = Modifier.padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Text("翻译引擎")
        state.available.forEach { id ->
            Button(
                onClick = { onSelect(id) },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(if (id == state.selected) "✓ $id" else id)
            }
        }
    }
}
