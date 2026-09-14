# LinguaLive

Android 原生实时直播翻译助手。

目标功能：
- 系统音频实时捕获
- 视频字幕 OCR 翻译
- 多翻译引擎（Google / DeepL / DeepSeek / OpenAI / 本地模型）
- 悬浮双语字幕
- GitHub Actions 自动构建 APK

## 本地实时语音链路

项目正在接入官方 sherpa-onnx Android Kotlin API：

`系统播放音频 → PCM → 16 kHz/512-sample frame → Silero VAD → ASR → 翻译 → 双语字幕`

当前代码使用 `com.k2fsa.sherpa.onnx.Vad`、`SileroVadModelConfig` 和 `VadModelConfig` 作为真实 VAD runtime 入口。官方 sherpa-onnx Android 文档提供了 Silero VAD Android 示例和预构建 Android runtime；模型文件应放入应用 assets 后由启动流程复制到应用私有目录。

注意：Android 9/API 28 不提供 Android 10 的公开 Playback Capture API，因此系统播放音频捕获仍由 API 29+ 路径负责，API 28 保持兼容降级。

**当前阶段暂不执行构建。** 等 sherpa-onnx runtime、模型和 ASR 链路全部移植完成后，再统一进行构建和修复。
