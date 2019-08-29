package com.kreditbee.flutterdemo

import android.os.Bundle
import com.facebook.FacebookSdk
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    FacebookSdk.setApplicationId("347226436183981")
    FacebookSdk.sdkInitialize(applicationContext)
    GeneratedPluginRegistrant.registerWith(this)
  }
}
