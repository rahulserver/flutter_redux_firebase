package com.example.flutter_redux_firebase

import android.annotation.TargetApi
import android.content.Intent
import android.os.Build
import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  @TargetApi(Build.VERSION_CODES.O)
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    startService(Intent(this, TweetingForegroundService::class.java));
    GeneratedPluginRegistrant.registerWith(this)
  }
}
