package com.lingualive.audio

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class AsrDecodeWorker(
    private val scope: CoroutineScope,
    private val runner: AsrInferenceRunner,
    private val onResult: (AsrDecodeResult) -> Unit
) {
    fun submit(request: AsrDecodeRequest) {
        scope.launch(Dispatchers.Default) { onResult(runner.run(request)) }
    }
}
