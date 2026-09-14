package com.lingualive.ocr

data class SubtitleRegion(
    val leftRatio: Float = 0f,
    val topRatio: Float = 0.65f,
    val rightRatio: Float = 1f,
    val bottomRatio: Float = 1f
) {
    init {
        require(leftRatio in 0f..1f && topRatio in 0f..1f &&
                rightRatio in 0f..1f && bottomRatio in 0f..1f)
        require(leftRatio < rightRatio && topRatio < bottomRatio)
    }

    fun toPixels(width: Int, height: Int): Rect =
        Rect(
            (leftRatio * width).toInt(),
            (topRatio * height).toInt(),
            (rightRatio * width).toInt(),
            (bottomRatio * height).toInt()
        )
}
