package com.example.safe_app;

import android.os.Bundle;
import android.view.WindowManager;
import android.content.res.Configuration;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.util.Log;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import androidx.annotation.NonNull;

public class MainActivity extends FlutterFragmentActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        // 覆盖系统字体缩放设置，防止文字过大
        Configuration configuration = getResources().getConfiguration();
        configuration.fontScale = 1.0f;  // 强制使用1.0的字体缩放
        getResources().updateConfiguration(configuration, getResources().getDisplayMetrics());
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}
