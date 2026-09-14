package com.lingualive.audio

import com.lingualive.settings.SettingsStore
import com.lingualive.translation.TranslationProviderId
import java.io.ByteArrayOutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.nio.ByteBuffer
import java.nio.ByteOrder
import org.json.JSONObject

class OpenAiWhisperEngine(private val settings: SettingsStore): AsrEngine {
 override val id="openai-whisper"
 override suspend fun transcribe(audio:ShortArray,sampleRate:Int):AsrResult? {
  val key=settings.providerConfig(TranslationProviderId.OPENAI).apiKey;if(key.isBlank())return null
  val wav=wav(audio,sampleRate);val boundary="----LinguaLive${System.nanoTime()}";val c=URL("https://api.openai.com/v1/audio/transcriptions").openConnection() as HttpURLConnection
  try{c.requestMethod="POST";c.connectTimeout=8000;c.readTimeout=30000;c.doOutput=true;c.setRequestProperty("Authorization","Bearer $key");c.setRequestProperty("Content-Type","multipart/form-data; boundary=$boundary")
   val out=c.outputStream;fun part(s:String){out.write(s.toByteArray())};part("--$boundary\r\nContent-Disposition: form-data; name=\"file\"; filename=\"live.wav\"\r\nContent-Type: audio/wav\r\n\r\n");out.write(wav);part("\r\n--$boundary\r\nContent-Disposition: form-data; name=\"model\"\r\n\r\nwhisper-1\r\n--$boundary--\r\n");out.close();val code=c.responseCode;if(code !in 200..299)return null;val text=c.inputStream.bufferedReader().use{it.readText()};val result=JSONObject(text).optString("text").trim();return result.takeIf{it.isNotBlank()}?.let{AsrResult(it)}
  }finally{c.disconnect()}
 }
 private fun wav(samples:ShortArray,rate:Int):ByteArray{val b=ByteArrayOutputStream();b.write("RIFF".toByteArray());val data=samples.size*2;val total=36+data;b.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(total).array());b.write("WAVEfmt ".toByteArray());b.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(16).array());b.write(ByteBuffer.allocate(2).order(ByteOrder.LITTLE_ENDIAN).putShort(1).array());b.write(ByteBuffer.allocate(2).order(ByteOrder.LITTLE_ENDIAN).putShort(1).array());b.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(rate).array());b.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(rate*2).array());b.write(ByteBuffer.allocate(2).order(ByteOrder.LITTLE_ENDIAN).putShort(2).array());b.write(ByteBuffer.allocate(2).order(ByteOrder.LITTLE_ENDIAN).putShort(16).array());b.write("data".toByteArray());b.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(data).array());for(s in samples)b.write(ByteBuffer.allocate(2).order(ByteOrder.LITTLE_ENDIAN).putShort(s).array());return b.toByteArray()}
}
