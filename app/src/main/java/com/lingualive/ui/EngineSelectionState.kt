package com.lingualive.ui

data class EngineSelectionState(
    val selected: String = "auto",
    val available: List<String> = listOf(
        "auto", "google", "deepl", "deepseek", "openai"
    )
) {
    fun select(id: String): EngineSelectionState =
        if (id in available) copy(selected = id) else this
}
