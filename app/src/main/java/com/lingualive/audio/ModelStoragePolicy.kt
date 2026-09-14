package com.lingualive.audio

import android.content.Context
import java.io.File

object ModelStoragePolicy {
    fun root(context: Context): File =
        File(context.getExternalFilesDir(null), "models/asr")
}
