package com.lingualive.capture

import android.app.*
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioRecord
import android.media.projection.MediaProjection
import android.os.Build
import android.os.Handler
import android.os.IBinder
import com.lingualive.audio.*
import com.lingualive.ocr.MlKitSubtitleRecognizer
import com.lingualive.ocr.OcrScript
import com.lingualive.ocr.OcrResult
import com.lingualive.ocr.LiveOcrPipeline
import com.lingualive.settings.SettingsStore
import com.lingualive.translation.LiveTranslationRuntime
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.collectLatest

class ScreenCaptureService:Service(){
 companion object{const val ACTION_START="com.lingualive.capture.START";const val ACTION_STOP="com.lingualive.capture.STOP";const val EXTRA_RESULT_CODE="result_code";const val EXTRA_PROJECTION_DATA="projection_data";const val EXTRA_WIDTH="width";const val EXTRA_HEIGHT="height";const val EXTRA_DPI="dpi";const val NOTIFICATION_CHANNEL="screen_capture";const val NOTIFICATION_ID=2001}
 private val scope=CoroutineScope(SupervisorJob()+Dispatchers.Default);private var ocrJob:Job?=null;private var asrJob:Job?=null;private var audioJob:Job?=null;private var adapter:ImageReaderAdapter?=null;private var projection:MediaProjection?=null;private var bridge:CaptureOcrBridge?=null;private var record:AudioRecord?=null;private var asr:AsrPipeline?=null;private val audioProcessor=AudioSignalProcessor();private val audioMeter=AudioLevelMeter();private val transcriptStabilizer=TranscriptStabilizer();private var capturedSamples=0L;private var droppedSamples=0L
 private val projectionCallback=object:MediaProjection.Callback(){override fun onStop(){stopResources(stopProjection=false);stopSelf()}}
 override fun onCreate(){super.onCreate();channel()}
 override fun onStartCommand(i:Intent?,f:Int,id:Int):Int{when(i?.action){ACTION_STOP->stopCapture();ACTION_START->startCapture(i)};return START_NOT_STICKY}
 private fun startCapture(i:Intent){val code=i.getIntExtra(EXTRA_RESULT_CODE,-1);val data=i.parcelableIntent(EXTRA_PROJECTION_DATA)?:run{stopSelf();return};val w=i.getIntExtra(EXTRA_WIDTH,1080);val h=i.getIntExtra(EXTRA_HEIGHT,1920);val dpi=i.getIntExtra(EXTRA_DPI,resources.displayMetrics.densityDpi);startForegroundCompat();stopResources();projection=MediaProjectionController(this).obtainProjection(code,data);projection?.registerCallback(projectionCallback,Handler(mainLooper))
  val settings=SettingsStore(this)
  val c=CaptureConfig(width=w,height=h,dpi=dpi)
  val script=when(settings.getString("source_language","auto").lowercase().substringBefore('-').substringBefore('_')){
   "zh" -> OcrScript.CHINESE
   "ja" -> OcrScript.JAPANESE
   "ko" -> OcrScript.KOREAN
   else -> OcrScript.LATIN
  }
  bridge=CaptureOcrBridge(c,LiveOcrPipeline(MlKitSubtitleRecognizer(script)));ocrJob=scope.launch{bridge!!.latest.collectLatest{r:OcrResult?->if(r!=null)LiveTranslationRuntime.get(this@ScreenCaptureService).submitOcr(r)}};adapter=ImageReaderAdapter(projection!!,c){b->bridge?.onFrame(b);b.recycle()}.also{it.start()}
  if(settings.getBoolean("audio",true)&&settings.providerConfig(com.lingualive.translation.TranslationProviderId.OPENAI).apiKey.isNotBlank())startAudio()
 }
 private fun startAudio(){if(Build.VERSION.SDK_INT<Build.VERSION_CODES.Q)return;val p=projection?:return;record=runCatching{AudioPlaybackCapture().createRecord(p,AudioCaptureConfig())}.getOrNull()?:return;asr=AsrPipeline(OpenAiWhisperEngine(SettingsStore(this)));val pipeline=asr!!;asrJob=scope.launch{pipeline.latest.collectLatest{r->if(r!=null){val stable=transcriptStabilizer.accept(r.text);if(stable!=null)LiveTranslationRuntime.get(this@ScreenCaptureService).submitSpeech(stable,r.timestampMs)}}};audioJob=scope.launch(Dispatchers.IO){val r=record?:return@launch;runCatching{r.startRecording();val buf=ShortArray(4000);while(isActive){val n=r.read(buf,0,buf.size);if(n>0){val pcm=buf.copyOf(n);audioMeter.update(pcm);capturedSamples+=n;val processed=audioProcessor.process(pcm);pipeline.submit(PcmChunk(processed,16000,System.currentTimeMillis()))}else if(n<0){droppedSamples+=buf.size;break}}}}}
 private fun stopCapture(){stopResources();stopSelf()}
 private fun stopResources(stopProjection:Boolean=true){ocrJob?.cancel();transcriptStabilizer.clear();audioMeter.reset();asrJob?.cancel();audioJob?.cancel();ocrJob=null;asrJob=null;audioJob=null;asr?.close();asr=null;record?.runCatching{stop()};record?.release();record=null;adapter?.close();adapter=null;bridge?.close();bridge=null;val p=projection;projection=null;if(p!=null){runCatching{p.unregisterCallback(projectionCallback)};if(stopProjection)runCatching{p.stop()}}}
 private fun startForegroundCompat(){val n=Notification.Builder(this,NOTIFICATION_CHANNEL).setContentTitle("LinguaLive").setContentText("正在实时识别屏幕与媒体音频").setSmallIcon(android.R.drawable.ic_menu_view).setOngoing(true).build();if(Build.VERSION.SDK_INT>=29)startForeground(NOTIFICATION_ID,n,ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION)else startForeground(NOTIFICATION_ID,n)}
 private fun channel(){if(Build.VERSION.SDK_INT>=26)getSystemService(NotificationManager::class.java).createNotificationChannel(NotificationChannel(NOTIFICATION_CHANNEL,"实时字幕采集",NotificationManager.IMPORTANCE_LOW))}
 override fun onDestroy(){stopResources();LiveTranslationRuntime.reset();scope.cancel();super.onDestroy()}
 override fun onBind(i:Intent?):IBinder?=null
}
@Suppress("DEPRECATION") private fun Intent.parcelableIntent(k:String):Intent?=if(Build.VERSION.SDK_INT>=33)getParcelableExtra(k,Intent::class.java)else getParcelableExtra(k)
