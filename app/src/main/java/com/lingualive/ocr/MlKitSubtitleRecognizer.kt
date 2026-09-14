package com.lingualive.ocr

import android.graphics.Bitmap
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

class MlKitSubtitleRecognizer {
    private val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

    suspend fun recognize(bitmap: Bitmap, timestampMs: Long = System.currentTimeMillis()): OcrResult =
        suspendCancellableCoroutine { continuation ->
            recognizer.process(InputImage.fromBitmap(bitmap, 0))
                .addOnSuccessListener { result ->
                    continuation.resume(
                        OcrResult(
                            text = OcrTextNormalizer.normalize(result.text),
                            confidence = 1f,
                            timestampMs = timestampMs
                        )
                    )
                }
                .addOnFailureListener { continuation.resumeWithException(it) }
        }

    fun close() = recognizer.close()
}
