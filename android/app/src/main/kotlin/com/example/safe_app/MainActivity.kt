package com.example.safe_app

import io.flutter.embedding.android.FlutterFragmentActivity
import android.content.res.Configuration
import android.os.Bundle

class MainActivity: FlutterFragmentActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 防止系统字体缩放影响应用
        val configuration = Configuration(resources.configuration)
        configuration.fontScale = 1.0f // 固定字体缩放为1.0
        resources.updateConfiguration(configuration, resources.displayMetrics)
    }
    
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        
        // 屏幕配置变化时也保持字体缩放固定
        val configuration = Configuration(newConfig)
        configuration.fontScale = 1.0f
        resources.updateConfiguration(configuration, resources.displayMetrics)
    }
} 