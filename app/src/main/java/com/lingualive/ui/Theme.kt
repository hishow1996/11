package com.lingualive.ui

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val Ink = Color(0xFF171717)
private val Paper = Color(0xFFF7F7F4)
private val Stone = Color(0xFFE8E8E2)
private val Accent = Color(0xFF2F5D50)
private val AccentSoft = Color(0xFFDCE8E2)

private val LightScheme = lightColorScheme(
    primary = Accent,
    onPrimary = Color.White,
    secondary = Color(0xFF6D756F),
    background = Paper,
    surface = Color.White,
    surfaceVariant = Stone,
    onBackground = Ink,
    onSurface = Ink
)

private val DarkScheme = darkColorScheme(
    primary = Color(0xFFA8C9BA),
    secondary = Color(0xFFB8C0BA),
    background = Color(0xFF121412),
    surface = Color(0xFF1A1C1A),
    surfaceVariant = Color(0xFF2A2D2A)
)

@Composable
fun LinguaTheme(darkTheme: Boolean = false, content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = if (darkTheme) DarkScheme else LightScheme,
        typography = Typography(),
        content = content
    )
}
