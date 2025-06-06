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

                // 设置窗口宽度为设计宽度的实际像素值
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
