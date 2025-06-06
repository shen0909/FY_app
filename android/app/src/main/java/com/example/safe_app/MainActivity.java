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
    private static final String TAG = "MainActivity";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        adjustWindowSizeForTablet();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        // 屏幕方向改变时重新调整窗口大小
        adjustWindowSizeForTablet();
    }

    // 调整平板设备的窗口大小
    private void adjustWindowSizeForTablet() {
        // 检测是否为平板设备
        boolean isTablet = (getResources().getConfiguration().screenLayout
                & Configuration.SCREENLAYOUT_SIZE_MASK)
                >= Configuration.SCREENLAYOUT_SIZE_LARGE;

        if (isTablet) {
            try {
                Log.d(TAG, "检测到平板设备，开始调整窗口大小...");

                // 覆盖系统字体缩放设置，防止文字过大
                Configuration configuration = getResources().getConfiguration();
                configuration.fontScale = 1.0f;  // 强制使用1.0的字体缩放
                getResources().updateConfiguration(configuration, getResources().getDisplayMetrics());

                // 获取屏幕尺寸
                DisplayMetrics displayMetrics = new DisplayMetrics();
                getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
                int screenWidth = displayMetrics.widthPixels;
                int screenHeight = displayMetrics.heightPixels;

                Log.d(TAG, "屏幕尺寸: " + screenWidth + "x" + screenHeight);

                // 获取状态栏高度
                int statusBarHeight = 0;
                int resourceId = getResources().getIdentifier("status_bar_height", "dimen", "android");
                if (resourceId > 0) {
                    statusBarHeight = getResources().getDimensionPixelSize(resourceId);
                }
                Log.d(TAG, "状态栏高度: " + statusBarHeight + "px");

                // 计算可用高度（屏幕高度 - 状态栏高度）
                int usableHeight = screenHeight - statusBarHeight;
                Log.d(TAG, "可用高度: " + usableHeight + "px");

                // 设计尺寸和比例
                int designWidth = 375;    // 设计宽度 (dp)
                int designHeight = 812;   // 设计高度 (dp)
                float aspectRatio = (float) designWidth / designHeight; // 宽高比 ≈ 0.462
                Log.d(TAG, "设计宽高比: " + aspectRatio);

                WindowManager.LayoutParams params = getWindow().getAttributes();

                // 策略1: 高度优先（高度设为100%可用高度）
                params.height = usableHeight;
                params.width = (int) (params.height * aspectRatio);
                Log.d(TAG, "策略1计算尺寸: " + params.width + "x" + params.height);

                // 检查宽度是否超过屏幕宽度
                if (params.width > screenWidth) {
                    Log.d(TAG, "宽度超过屏幕宽度，采用策略2");

                    // 策略2: 宽度优先（宽度设为100%屏幕宽度）
                    params.width = screenWidth;
                    params.height = (int) (params.width / aspectRatio);
                    Log.d(TAG, "策略2计算尺寸: " + params.width + "x" + params.height);

                    // 检查高度是否超过可用高度
                    if (params.height > usableHeight) {
                        Log.d(TAG, "高度超过可用高度，进行高度限制");

                        // 策略3: 高度限制（高度设为100%可用高度，宽度重新计算）
                        params.height = usableHeight;
                        params.width = (int) (params.height * aspectRatio);
                        Log.d(TAG, "策略3最终尺寸: " + params.width + "x" + params.height);
                    }
                }

                // 应用窗口参数
                getWindow().setAttributes(params);
                Log.d(TAG, "应用窗口尺寸: " + params.width + "x" + params.height);

                // 设置窗口位置为居中
                getWindow().setGravity(Gravity.CENTER);
                Log.d(TAG, "窗口位置设置为居中");

            } catch (Exception e) {
                Log.e(TAG, "调整窗口大小时出错", e);
                e.printStackTrace();
            }
        } else {
            Log.d(TAG, "非平板设备，保持全屏显示");
        }
    }
}