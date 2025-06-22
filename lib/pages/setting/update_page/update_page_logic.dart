import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:safe_app/services/update_service.dart';
import 'package:safe_app/utils/toast_util.dart';

import 'update_page_state.dart';

class UpdatePageLogic extends GetxController {
  final UpdatePageState state = UpdatePageState();

  @override
  void onReady() {
    super.onReady();
    checkUpdate();
  }

  @override
  void onClose() {
    cancelDownloadIfNeeded();
    super.onClose();
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
    if (state.isDownloading && state.cancelToken != null && !state.cancelToken!.isCancelled) {
      state.cancelToken!.cancel('用户取消下载');
      state.isDownloading = false;
      state.downloadProgress = 0;
      state.errorMessage = '下载已取消';
      update();
    }
  }

  /// 下载更新
  Future<void> downloadUpdate() async {
    if (state.isDownloading || state.isInstalling) {
      return;
    }
    
    state.isDownloading = true;
    state.downloadProgress = 0;
    state.errorMessage = '';
    state.cancelToken = CancelToken();
    update();
    
    try {
      final filePath = await UpdateService().downloadUpdate(
        state.updateInfo!['uuid'],
        state.updateInfo!['filename'],
        onProgress: (progress) {
          state.downloadProgress = progress;
          update();
        },
        cancelToken: state.cancelToken
      );
      
      state.isDownloading = false;
      state.downloadProgress = 0;
      update();
      
      if (filePath == null) {
        state.errorMessage = '下载失败';
        update();
        return;
      }
      
      // 下载完成后开始安装
      state.isInstalling = true;
      update();
      
      // 调用安装方法
      await installUpdate(filePath);
      
      state.isInstalling = false;
      update();
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('下载更新异常: ${e.message}');
      }
      
      state.isDownloading = false;
      state.downloadProgress = 0;
      if (e.type == DioExceptionType.cancel) {
        state.errorMessage = '下载已取消';
      } else {
        state.errorMessage = '下载失败: ${e.message}';
      }
      update();
    } catch (e) {
      if (kDebugMode) {
        print('下载更新异常: $e');
      }
      
      state.isDownloading = false;
      state.downloadProgress = 0;
      state.errorMessage = '下载失败: $e';
      update();
    }
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
      // 显示安装确认对话框
      bool confirm = await showInstallConfirmDialog();
      if (!confirm) {
        return;
      }
      
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
