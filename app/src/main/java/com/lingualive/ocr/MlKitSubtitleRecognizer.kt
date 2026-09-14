package com.lingualive.ocr

import android.graphics.Bitmap
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
import com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
import com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.math.abs
import kotlin.math.max

enum class OcrScript {
    LATIN,
    CHINESE,
    JAPANESE,
    KOREAN
}

class MlKitSubtitleRecognizer(
    script: OcrScript = OcrScript.LATIN
) {
    private val recognizer: TextRecognizer = when (script) {
        OcrScript.LATIN -> TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
        OcrScript.CHINESE -> TextRecognition.getClient(ChineseTextRecognizerOptions.Builder().build())
        OcrScript.JAPANESE -> TextRecognition.getClient(JapaneseTextRecognizerOptions.Builder().build())
        OcrScript.KOREAN -> TextRecognition.getClient(KoreanTextRecognizerOptions.Builder().build())
    }

    suspend fun recognize(bitmap: Bitmap, timestampMs: Long = System.currentTimeMillis()): OcrResult =
        suspendCancellableCoroutine { continuation ->
            recognizer.process(InputImage.fromBitmap(bitmap, 0))
                .addOnSuccessListener { result ->
                    val detected = result.textBlocks
                        .flatMap { it.lines }
                        .mapNotNull { line ->
                            val text = line.text.trim()
                            if (!OcrTextNormalizer.isUseful(text)) return@mapNotNull null
                            val box = line.boundingBox?.let { Rect(it.left, it.top, it.right, it.bottom) }
                            OcrLine(OcrTextNormalizer.normalize(text), box)
                        }
                        .sortedWith(compareBy<OcrLine> { it.bounds?.top ?: Int.MAX_VALUE }
                            .thenBy { it.bounds?.left ?: Int.MAX_VALUE })

                    val grouped = groupLines(detected)
                    val merged = grouped.joinToString("\n") { row ->
                        row.joinToString(" ") { it.text }
                    }.trim()
                    val bounds = detected.mapNotNull { it.bounds }.reduceOrNull(::union)
                    continuation.resume(OcrResult(merged, 1f, timestampMs, bounds, detected))
                }
                .addOnFailureListener { continuation.resumeWithException(it) }
        }

    private fun groupLines(lines: List<OcrLine>): List<List<OcrLine>> {
        if (lines.isEmpty()) return emptyList()
        val heights = lines.mapNotNull { it.bounds?.let { b -> (b.bottom - b.top).coerceAtLeast(1) } }
        val medianHeight = heights.sorted().getOrNull(heights.size / 2) ?: 12
        val tolerance = (medianHeight * 0.7f).coerceAtLeast(8f)
        val rows = mutableListOf<MutableList<OcrLine>>()
        val centers = mutableListOf<Float>()

        for (line in lines) {
            val box = line.bounds
            if (box == null) {
                rows += mutableListOf(line)
                centers += Float.MAX_VALUE
                continue
            }
            val center = (box.top + box.bottom) / 2f
            val rowIndex = centers.indices.minByOrNull { abs(centers[it] - center) }
            if (rowIndex != null && abs(centers[rowIndex] - center) <= tolerance) {
                rows[rowIndex] += line
                centers[rowIndex] = rows[rowIndex].mapNotNull { it.bounds }
                    .map { (it.top + it.bottom) / 2f }.average().toFloat()
            } else {
                rows += mutableListOf(line)
                centers += center
            }
        }

        return rows.map { row -> row.sortedBy { it.bounds?.left ?: Int.MAX_VALUE } }
            .sortedBy { row -> row.firstOrNull()?.bounds?.top ?: Int.MAX_VALUE }
    }

    private fun union(a: Rect, b: Rect): Rect = Rect(
        minOf(a.left, b.left),
        minOf(a.top, b.top),
        max(a.right, b.right),
        max(a.bottom, b.bottom)
    )

    fun close() = recognizer.close()
}
