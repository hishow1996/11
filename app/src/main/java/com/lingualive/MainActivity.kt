package com.lingualive

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.lingualive.capture.ScreenCaptureService
import com.lingualive.settings.SettingsStore
import com.lingualive.translation.LiveTranslationRuntime
import com.lingualive.ui.*

class MainActivity:ComponentActivity(){
 private val pm by lazy{getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager};private val store by lazy{SettingsStore(this)};private var running by mutableStateOf(false);private var page by mutableStateOf("home")
 override fun onCreate(s:Bundle?){super.onCreate(s);setContent{LinguaTheme{Surface(Modifier.fillMaxSize()){when(page){"settings"->SettingsScreen(store){page="home"};"style"->StyleScreen(store){page="home"};"history"->HistoryScreen(LiveTranslationRuntime.get(this).lines.collectAsState(emptyList()).value,{LiveTranslationRuntime.get(this).clear()}){page="home"};else->HomeScreen(running,{if(running)stopCapture()else requestCapture()},{page="settings"},{page="style"},{page="history"})}}}}}
 private val launcher=registerForActivityResult(ActivityResultContracts.StartActivityForResult()){r->if(r.resultCode==Activity.RESULT_OK&&r.data!=null){val m=resources.displayMetrics;startService(Intent(this,ScreenCaptureService::class.java).apply{action=ScreenCaptureService.ACTION_START;putExtra(ScreenCaptureService.EXTRA_RESULT_CODE,r.resultCode);putExtra(ScreenCaptureService.EXTRA_PROJECTION_DATA,r.data);putExtra(ScreenCaptureService.EXTRA_WIDTH,m.widthPixels);putExtra(ScreenCaptureService.EXTRA_HEIGHT,m.heightPixels);putExtra(ScreenCaptureService.EXTRA_DPI,m.densityDpi)});running=true}}
 private fun requestCapture(){launcher.launch(pm.createScreenCaptureIntent())};private fun stopCapture(){startService(Intent(this,ScreenCaptureService::class.java).setAction(ScreenCaptureService.ACTION_STOP));running=false}
}
@Composable private fun HomeScreen(running:Boolean,onStart:()->Unit,onSettings:()->Unit,onStyle:()->Unit,onHistory:()->Unit){Column(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background).padding(horizontal=22.dp,vertical=28.dp),verticalArrangement=Arrangement.spacedBy(14.dp)){Row(Modifier.fillMaxWidth(),horizontalArrangement=Arrangement.SpaceBetween,verticalAlignment=Alignment.CenterVertically){Column{Text("LinguaLive",style=MaterialTheme.typography.headlineMedium);Text(if(running)"正在安静地工作" else "Live translation, quietly.",style=MaterialTheme.typography.bodyMedium,color=MaterialTheme.colorScheme.secondary)};StatusPill(if(running)"运行中" else "待机",running)};SectionCard("实时翻译"){Text("把正在播放的内容变成自然的中文双语字幕。",style=MaterialTheme.typography.bodyLarge);Spacer(Modifier.height(16.dp));Row(horizontalArrangement=Arrangement.spacedBy(8.dp)){StatusPill("屏幕 OCR",true);StatusPill("媒体音频",true);StatusPill("中文",true)};Spacer(Modifier.height(16.dp));Button(onStart,Modifier.fillMaxWidth().height(52.dp)){Text(if(running)"停止翻译" else "开始翻译")}};SectionCard("工作状态"){MetricRow(listOf("目标语言" to "中文","字幕" to "双语","引擎" to "自动"))};Row(Modifier.fillMaxWidth(),horizontalArrangement=Arrangement.spacedBy(10.dp)){OutlinedButton(onSettings,Modifier.weight(1f)){Text("翻译设置")};OutlinedButton(onStyle,Modifier.weight(1f)){Text("字幕样式")}};OutlinedButton(onHistory,Modifier.fillMaxWidth()){Text("查看最近字幕")};Spacer(Modifier.weight(1f));Text("首次使用时，请允许屏幕采集与悬浮窗权限。",style=MaterialTheme.typography.bodySmall,color=MaterialTheme.colorScheme.secondary)}}
