package com.example.safe_app;

import android.os.Bundle;
import android.view.WindowManager;
import android.content.res.Configuration;
import android.util.DisplayMetrics;
import android.view.Gravity;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import androidx.annotation.NonNull;

public class MainActivity extends FlutterFragmentActivity {
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
                // 覆盖系统字体缩放设置，防止文字过大
                Configuration configuration = getResources().getConfiguration();
                configuration.fontScale = 1.0f;  // 强制使用1.0的字体缩放
                getResources().updateConfiguration(configuration, getResources().getDisplayMetrics());

                // 获取屏幕尺寸
                DisplayMetrics displayMetrics = new DisplayMetrics();
                getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);

                // 计算屏幕宽高
                int screenWidth = displayMetrics.widthPixels;
                int screenHeight = displayMetrics.heightPixels;

                // 设置窗口大小为固定尺寸
                WindowManager.LayoutParams params = getWindow().getAttributes();

                // 使用Flutter设计尺寸的实际值
                int designWidth = 375;
                int designHeight = 812;

                // 计算缩放因子
                float scaleFactor = getResources().getDisplayMetrics().density;

                // 检查当前是横屏还是竖屏
                boolean isLandscape = getResources().getConfiguration().orientation
                        == Configuration.ORIENTATION_LANDSCAPE;

                if (isLandscape) {
                    // 横屏模式下，保持设计尺寸的比例，但窗口居中显示
                    // 窗口高度设为屏幕高度的90%
                    params.height = (int)(screenHeight * 0.9);
                    // 根据设计比例计算对应的宽度
                    params.width = (int)(params.height * ((float)designWidth / designHeight));

                    // 确保宽度不超过屏幕宽度的90%
                    if (params.width > screenWidth * 0.9) {
                        float ratio = (float)params.width / (screenWidth * 0.9f);
                        params.width = (int)(screenWidth * 0.9);
                        params.height = (int)(params.height / ratio);
                    }
                } else {
                    // 竖屏模式，使用原来的计算方式
                    params.width = (int)(designWidth * scaleFactor);
                    params.height = (int)(designHeight * scaleFactor);

                    // 确保窗口不超过屏幕的限制
                    if (params.width > screenWidth * 0.9) {
                        float ratio = (float)params.width / (screenWidth * 0.9f);
                        params.width = (int)(screenWidth * 0.9);
                        params.height = (int)(params.height / ratio);
                    }

                    if (params.height > screenHeight * 0.9) {
                        float ratio = (float)params.height / (screenHeight * 0.9f);
                        params.height = (int)(screenHeight * 0.9);
                        params.width = (int)(params.width / ratio);
                    }
                }

                // 应用窗口参数
                getWindow().setAttributes(params);

                // 设置窗口位置为居中
                getWindow().setGravity(Gravity.CENTER);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
