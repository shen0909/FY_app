package com.example.safe_app

import io.flutter.embedding.android.FlutterFragmentActivity
import android.content.res.Configuration
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.MediaScannerConnection
import android.provider.MediaStore
import android.content.ContentValues
import android.os.Environment
import java.io.File
import java.io.FileInputStream
import java.io.OutputStream
import android.view.WindowManager
import android.database.ContentObserver
import android.os.Handler
import android.net.Uri
import android.util.Log

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL_MEDIA = "com.example.safe_app/media"
    private var screenshotObserver: ContentObserver? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 设置防截屏标志
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
        
        // 防止系统字体缩放影响应用
        val configuration = Configuration(resources.configuration)
        configuration.fontScale = 1.0f // 固定字体缩放为1.0
        resources.updateConfiguration(configuration, resources.displayMetrics)
        
        // 初始化截屏监听
        initScreenshotObserver()
    }
    
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        
        // 屏幕配置变化时也保持字体缩放固定
        val configuration = Configuration(newConfig)
        configuration.fontScale = 1.0f
        resources.updateConfiguration(configuration, resources.displayMetrics)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_MEDIA).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanFile" -> {
                    val path: String? = call.argument("path")
                    if (path.isNullOrEmpty()) {
                        result.error("NO_PATH", "path is null or empty", null)
                    } else {
                        try {
                            MediaScannerConnection.scanFile(this, arrayOf(path), null) { _, _ -> }
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SCAN_FAILED", e.message, null)
                        }
                    }
                }
                "saveToDownloads" -> {
                    val path: String? = call.argument("path")
                    val fileName: String? = call.argument("fileName")
                    if (path.isNullOrEmpty() || fileName.isNullOrEmpty()) {
                        result.error("INVALID_ARGS", "path or fileName is null", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val file = File(path)
                        if (!file.exists()) {
                            result.error("NO_FILE", "source file not found", null)
                            return@setMethodCallHandler
                        }
                        val resolver = contentResolver
                        val values = ContentValues().apply {
                            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                            put(MediaStore.Downloads.MIME_TYPE, "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
                            put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                        }
                        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                        if (uri == null) {
                            result.error("INSERT_FAILED", "cannot insert into downloads", null)
                            return@setMethodCallHandler
                        }
                        resolver.openOutputStream(uri).use { outStream: OutputStream? ->
                            FileInputStream(file).use { fis ->
                                val buffer = ByteArray(8 * 1024)
                                var bytesRead: Int
                                while (true) {
                                    bytesRead = fis.read(buffer)
                                    if (bytesRead == -1) break
                                    outStream?.write(buffer, 0, bytesRead)
                                }
                                outStream?.flush()
                            }
                        }
                        // 返回预期的公开路径
                        val publicPath = "/storage/emulated/0/Download/$fileName"
                        // 触发媒体扫描，确保立即可见
                        MediaScannerConnection.scanFile(this, arrayOf(publicPath), null) { _, _ -> }
                        result.success(publicPath)
                    } catch (e: Exception) {
                        result.error("SAVE_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
    
    /**
     * 初始化截屏监听器
     */
    private fun initScreenshotObserver() {
        screenshotObserver = object : ContentObserver(Handler()) {
            override fun onChange(selfChange: Boolean, uri: Uri?) {
                super.onChange(selfChange, uri)
                if (uri != null && uri.toString().contains("screenshot")) {
                    Log.w("MainActivity", "检测到截屏尝试")
                    // 这里可以添加截屏后的处理逻辑，比如显示警告
                    // 由于FLAG_SECURE已经阻止了截屏，这里主要是记录日志
                }
            }
        }
        
        // 注册截屏监听器
        contentResolver.registerContentObserver(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            true,
            screenshotObserver!!
        )
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // 注销截屏监听器
        screenshotObserver?.let {
            contentResolver.unregisterContentObserver(it)
        }
    }
    
    override fun onResume() {
        super.onResume()
        // 确保防截屏标志在应用恢复时仍然有效
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }
}