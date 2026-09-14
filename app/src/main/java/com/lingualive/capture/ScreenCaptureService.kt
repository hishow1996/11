package com.lingualive.capture

import android.app.*
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioRecord
import android.media.projection.MediaProjection
import android.os.Build
import android.os.IBinder
import com.lingualive.audio.*
import com.lingualive.ocr.OcrResult
import com.lingualive.settings.SettingsStore
import com.lingualive.translation.LiveTranslationRuntime
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.collectLatest

class ScreenCaptureService:Service(){
 companion object{const val ACTION_START="com.lingualive.capture.START";const val ACTION_STOP="com.lingualive.capture.STOP";const val EXTRA_RESULT_CODE="result_code";const val EXTRA_PROJECTION_DATA="projection_data";const val EXTRA_WIDTH="width";const val EXTRA_HEIGHT="height";const val EXTRA_DPI="dpi";const val NOTIFICATION_CHANNEL="screen_capture";const val NOTIFICATION_ID=2001}
 private val scope=CoroutineScope(SupervisorJob()+Dispatchers.Default);private var ocrJob:Job?=null;private var asrJob:Job?=null;private var audioJob:Job?=null;private var adapter:ImageReaderAdapter?=null;private var projection:MediaProjection?=null;private var bridge:CaptureOcrBridge?=null;private var record:AudioRecord?=null;private var asr:AsrPipeline?=null
 override fun onCreate(){super.onCreate();channel()}
 override fun onStartCommand(i:Intent?,f:Int,id:Int):Int{when(i?.action){ACTION_STOP->stopCapture();ACTION_START->startCapture(i)};return START_NOT_STICKY}
 private fun startCapture(i:Intent){val code=i.getIntExtra(EXTRA_RESULT_CODE,-1);val data=i.parcelableIntent(EXTRA_PROJECTION_DATA)?:run{stopSelf();return};val w=i.getIntExtra(EXTRA_WIDTH,1080);val h=i.getIntExtra(EXTRA_HEIGHT,1920);val dpi=i.getIntExtra(EXTRA_DPI,resources.displayMetrics.densityDpi);startForegroundCompat();stopResources();projection=MediaProjectionController(this).obtainProjection(code,data)
  val c=CaptureConfig(width=w,height=h,dpi=dpi);bridge=CaptureOcrBridge(c);ocrJob=scope.launch{bridge!!.latest.collectLatest{r:OcrResult?->if(r!=null)LiveTranslationRuntime.get(this@ScreenCaptureService).submitOcr(r)}};adapter=ImageReaderAdapter(projection!!,c){b->bridge?.onFrame(b);b.recycle()}.also{it.start()}
  val settings=SettingsStore(this);if(settings.getBoolean("audio",true)&&settings.providerConfig(com.lingualive.translation.TranslationProviderId.OPENAI).apiKey.isNotBlank())startAudio()
 }
 private fun startAudio(){val p=projection?:return;record=runCatching{AudioPlaybackCapture().createRecord(p,AudioCaptureConfig())}.getOrNull()?:return;asr=AsrPipeline(OpenAiWhisperEngine(SettingsStore(this)));val pipeline=asr!!;asrJob=scope.launch{pipeline.latest.collectLatest{r->if(r!=null)LiveTranslationRuntime.get(this@ScreenCaptureService).submitSpeech(r.text,r.timestampMs)}};audioJob=scope.launch(Dispatchers.IO){val r=record?:return@launch;runCatching{r.startRecording();val buf=ShortArray(8000);while(isActive){val n=r.read(buf,0,buf.size);if(n>0)pipeline.submit(PcmChunk(buf.copyOf(n),16000,System.currentTimeMillis()))}}}}
 private fun stopCapture(){stopResources();stopSelf()}
 private fun stopResources(){ocrJob?.cancel();asrJob?.cancel();audioJob?.cancel();ocrJob=null;asrJob=null;audioJob=null;asr?.close();asr=null;record?.runCatching{stop()};record?.release();record=null;adapter?.close();adapter=null;projection?.stop();projection=null;bridge?.close();bridge=null}
 private fun startForegroundCompat(){val n=Notification.Builder(this,NOTIFICATION_CHANNEL).setContentTitle("LinguaLive").setContentText("正在实时识别屏幕与媒体音频").setSmallIcon(android.R.drawable.ic_menu_view).setOngoing(true).build();if(Build.VERSION.SDK_INT>=29)startForeground(NOTIFICATION_ID,n,ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION)else startForeground(NOTIFICATION_ID,n)}
 private fun channel(){if(Build.VERSION.SDK_INT>=26)getSystemService(NotificationManager::class.java).createNotificationChannel(NotificationChannel(NOTIFICATION_CHANNEL,"实时字幕采集",NotificationManager.IMPORTANCE_LOW))}
 override fun onDestroy(){stopResources();LiveTranslationRuntime.reset();scope.cancel();super.onDestroy()}
 override fun onBind(i:Intent?):IBinder?=null
}
@Suppress("DEPRECATION") private fun Intent.parcelableIntent(k:String):Intent?=if(Build.VERSION.SDK_INT>=33)getParcelableExtra(k,Intent::class.java)else getParcelableExtra(k)
