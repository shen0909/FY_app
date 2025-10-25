import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:safe_app/services/update_service.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'update_page_state.dart';

// 全局单例，用于保持下载状态
class UpdateManager {
  static final UpdateManager _instance = UpdateManager._internal();
  factory UpdateManager() => _instance;
  UpdateManager._internal();
  
  CancelToken? cancelToken;
  bool isDownloading = false;
  double downloadProgress = 0.0;
  String? downloadedFilePath;
  bool isInstalling = false;
}

class UpdatePageLogic extends GetxController {
  final UpdatePageState state = UpdatePageState();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // 使用全局单例管理下载状态
  final UpdateManager updateManager = UpdateManager();

  // 添加一个变量来记录上次通知的进度百分比，防止频繁更新
  int _lastNotifiedProgress = 0;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
    // 从全局状态同步到本地状态
    _syncFromGlobalState();
  }

  // 同步全局状态到本地状态
  void _syncFromGlobalState() {
    state.isDownloading = updateManager.isDownloading;
    state.downloadProgress = updateManager.downloadProgress;
    state.cancelToken = updateManager.cancelToken;
    state.downloadedFilePath = updateManager.downloadedFilePath;
    state.isInstalling = updateManager.isInstalling;
    update();
  }

  @override
  void onReady() {
    super.onReady();
    checkUpdate();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // 初始化通知
  Future<void> _initNotifications() async {
    // 请求通知权限
    await _requestNotificationPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        // 处理通知点击事件
        if (notificationResponse.payload == 'update_completed') {
          _showInstallDialog();
        }
      },
    );
  }
  
  // 请求通知权限
  Future<void> _requestNotificationPermission() async {
    if (Platform.isAndroid) {
      // Android 13 (API 33)及以上需要明确请求通知权限
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
  }

  // 检查更新
  Future<void> checkUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    state.currentVersion = packageInfo.version;
    
    state.isLoading = true;
    state.errorMessage = '';
    update();

    try {
      final updateInfo = await UpdateService().checkUpdate();
      
      state.isLoading = false;
      state.updateInfo = updateInfo;
      update();
    } catch (e) {
      state.isLoading = false;
      state.errorMessage = '检查更新失败: $e';
      update();
    }
  }

  // 取消下载
  void cancelDownloadIfNeeded() {
    if (updateManager.isDownloading && updateManager.cancelToken != null && !updateManager.cancelToken!.isCancelled) {
      updateManager.cancelToken!.cancel('用户取消下载');
      updateManager.isDownloading = false;
      updateManager.downloadProgress = 0;
      
      // 同步到本地状态
      state.isDownloading = false;
      state.downloadProgress = 0;
      state.errorMessage = '下载已取消';
      update();
      
      // 取消通知
      flutterLocalNotificationsPlugin.cancel(1);
    }
  }

  /// 下载更新 - 同时支持前台和后台
  Future<void> downloadUpdate() async {
    if (updateManager.isDownloading || updateManager.isInstalling) {
      return;
    }

    // 重置上次通知的进度
    _lastNotifiedProgress = 0;

    // 更新全局状态
    updateManager.isDownloading = true;
    updateManager.downloadProgress = 0;
    updateManager.cancelToken = CancelToken();
    
    // 同步到本地状态
    state.isDownloading = true;
    state.downloadProgress = 0;
    state.errorMessage = '';
    state.cancelToken = updateManager.cancelToken;
    update();
    
    // 显示通知
    await _showDownloadingNotification();
    
    try {
      final filePath = await UpdateService().downloadUpdate(
          state.updateInfo!['uuid'],
          state.updateInfo!['filename'],
          onProgress: (progress) {
            // 更新全局进度
            updateManager.downloadProgress = progress;
            // 同步到本地状态（如果页面还在显示）
            state.downloadProgress = progress;
            update();

            // 基于进度百分比更新通知，每增加5%或下载完成时更新一次
            final int currentProgressInt = (progress * 100).round();
            if (currentProgressInt - _lastNotifiedProgress >= 5 || progress == 1.0) {
              _updateDownloadNotification(progress);
              _lastNotifiedProgress = currentProgressInt;
            }
          },
          cancelToken: updateManager.cancelToken
      );
      
      // 更新全局状态
      updateManager.isDownloading = false;
      updateManager.downloadProgress = 0;
      
      // 同步到本地状态
      state.isDownloading = false;
      state.downloadProgress = 0;
      update();
      
      if (filePath == null) {
        state.errorMessage = '下载失败';
        update();
        _showDownloadFailedNotification();
        return;
      }
      
      updateManager.downloadedFilePath = filePath;
      state.downloadedFilePath = filePath;
      
      // 下载完成通知
      _showDownloadCompletedNotification();
      
      // 显示安装确认对话框
      await _showInstallDialog();
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('下载更新异常: ${e.message}');
      }
      
      updateManager.isDownloading = false;
      updateManager.downloadProgress = 0;
      state.isDownloading = false;
      state.downloadProgress = 0;
      if (e.type == DioExceptionType.cancel) {
        state.errorMessage = '下载已取消';
        _showDownloadCancelledNotification();
      } else {
        state.errorMessage = '下载失败: ${e.message}';
        _showDownloadFailedNotification();
      }
      update();
    } catch (e) {
      if (kDebugMode) {
        print('下载更新异常: $e');
      }
      
      updateManager.isDownloading = false;
      updateManager.downloadProgress = 0;
      state.isDownloading = false;
      state.downloadProgress = 0;
      state.errorMessage = '下载失败: $e';
      _showDownloadFailedNotification();
      update();
    }
  }

  // 显示下载中通知
  Future<void> _showDownloadingNotification() async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'update_channel',
      '应用更新',
      channelDescription: '应用更新下载进度',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: 0,
      ongoing: true,
      autoCancel: false,
    );
    
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      ),
    );
    
    await flutterLocalNotificationsPlugin.show(
      1, // 通知ID
      '正在下载更新',
      '下载进度: 0%',
      notificationDetails,
    );
  }

  // 更新下载进度通知
  Future<void> _updateDownloadNotification(double progress) async {
    final int progressInt = (progress * 100).round();
    print("更新下载进度:$progressInt");
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'update_channel',
      '应用更新',
      channelDescription: '应用更新下载进度',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: progressInt,
      ongoing: true,
      autoCancel: false,
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      ),
    );
    
    await flutterLocalNotificationsPlugin.show(
      1, // 通知ID
      '正在下载更新',
      '下载进度: $progressInt%',
      notificationDetails,
    );
  }

  // 显示下载完成通知
  Future<void> _showDownloadCompletedNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'update_channel',
      '应用更新',
      channelDescription: '应用更新下载进度',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    
    await flutterLocalNotificationsPlugin.show(
      1, // 通知ID
      '更新下载完成',
      '点击安装新版本',
      notificationDetails,
      payload: 'update_completed',
    );
  }

  // 显示下载失败通知
  Future<void> _showDownloadFailedNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'update_channel',
      '应用更新',
      channelDescription: '应用更新下载进度',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    
    await flutterLocalNotificationsPlugin.show(
      1, // 通知ID
      '更新下载失败',
      '请重新尝试下载',
      notificationDetails,
    );
  }

  // 显示下载取消通知
  Future<void> _showDownloadCancelledNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'update_channel',
      '应用更新',
      channelDescription: '应用更新下载进度',
      importance: Importance.low,
      priority: Priority.low,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    
    await flutterLocalNotificationsPlugin.show(
      1, // 通知ID
      '下载已取消',
      '更新下载已取消',
      notificationDetails,
    );
  }

  // 显示安装确认对话框
  Future<void> _showInstallDialog() async {
    if (updateManager.downloadedFilePath == null) return;
    
    // 显示安装确认对话框
    bool confirm = await showInstallConfirmDialog();
    if (!confirm) {
      return;
    }
    
    // 开始安装（更新全局和本地状态）
    updateManager.isInstalling = true;
    state.isInstalling = true;
    update();
    
    // 调用安装服务
    await installUpdate(updateManager.downloadedFilePath!);
    
    // 安装完成（更新全局和本地状态）
    updateManager.isInstalling = false;
    state.isInstalling = false;
    update();
  }

  // 显示安装确认对话框
  Future<bool> showInstallConfirmDialog() async {
    try {
      return await Get.dialog<bool>(
        WillPopScope(
          onWillPop: () async => false, // 防止返回键关闭对话框
          child: AlertDialog(
            title: const Text('安装更新'),
            content: const Text('下载完成，是否立即安装更新？'),
            actions: <Widget>[
              TextButton(
                child: const Text('取消'),
                onPressed: () {
                  Get.back(result: false);
                },
              ),
              TextButton(
                child: const Text('安装'),
                onPressed: () {
                  Get.back(result: true);
                },
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      ) ?? false; // 如果对话框被意外关闭，返回false
    } catch (e) {
      if (kDebugMode) {
        print('显示安装确认对话框出错: $e');
      }
      return false;
    }
  }

  /// 安装更新
  Future<void> installUpdate(String filePath) async {
    try {
      // 调用安装服务
      bool result = await UpdateService().installUpdate(filePath);
      
      if (!result) {
        ToastUtil.showError('安装失败，请检查是否授予安装权限');
      }
    } catch (e) {
      if (kDebugMode) {
        print('安装更新异常: $e');
      }
      ToastUtil.showError('安装过程中出现异常');
    }
  }
}
