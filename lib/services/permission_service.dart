import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'dart:io';

/// 权限管理服务
/// 用于统一处理应用中的各种权限请求
class PermissionService {
  /// 请求存储权限
  static Future<bool> requestStoragePermission(BuildContext? context) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      // 非移动平台默认返回true
      return true;
    }
    
    if (context == null) {
      // 如果没有上下文，直接请求权限（兼容旧代码）
      return await _requestStoragePermissionDirect();
    }
    
    // 先检查当前权限状态
    final currentStatus = await _checkStoragePermissionStatus();
    
    if (currentStatus.isGranted) {
      return true;
    }
    
    // 如果权限被永久拒绝，直接引导用户去设置
    if (currentStatus.isPermanentlyDenied) {
      if (context.mounted) {
        return await _showPermissionPermanentlyDeniedDialog(context, '存储');
      }
      return false;
    }
    
    // 显示权限请求说明对话框
    if (context.mounted) {
      final userWantsToGrant = await _showPermissionRequestDialog(
        context,
        '存储权限',
        '为了能够导出和保存文件到您的设备，我们需要访问存储权限。\n\n• 导出AI对话记录\n• 保存下载的文件\n• 版本更新文件存储',
      );
      
      if (!userWantsToGrant) {
        return false;
      }
    }
    
    // 用户同意后，请求权限
    return await _requestStoragePermissionDirect();
  }
  
  /// 直接请求存储权限（内部方法）
  static Future<bool> _requestStoragePermissionDirect() async {
    if (Platform.isAndroid) {
      // Android平台 - 尝试多种权限请求方式
      
      // 1. 先尝试存储权限
      var storage = await Permission.storage.request();
      
      // 2. 如果失败，尝试外部存储权限
      if (!storage.isGranted) {
        storage = await Permission.manageExternalStorage.request();
      }
      
      // 3. 如果还是失败，尝试媒体权限（Android 13+）
      if (!storage.isGranted) {
        final mediaImages = await Permission.photos.request();
        if (mediaImages.isGranted) {
          return true;
        }
      }
      
      if (storage.isPermanentlyDenied) {
        ToastUtil.showShort("存储权限被拒绝，请在设置中手动开启");
        return false;
      } else if (storage.isDenied) {
        ToastUtil.showShort("存储权限被拒绝，无法保存文件");
        return false;
      }
      
      return storage.isGranted;
    } else if (Platform.isIOS) {
      // iOS平台请求相册权限
      final photos = await Permission.photos.request();
      
      if (photos.isPermanentlyDenied) {
        ToastUtil.showShort("相册权限被拒绝，请在设置中手动开启");
        return false;
      } else if (photos.isDenied) {
        ToastUtil.showShort("相册权限被拒绝，无法保存文件");
        return false;
      }
      
      return photos.isGranted;
    }
    
    return false;
  }
  
  /// 检查存储权限状态
  static Future<PermissionStatus> _checkStoragePermissionStatus() async {
    if (Platform.isAndroid) {
      // 先检查基本存储权限
      var storage = await Permission.storage.status;
      if (storage.isGranted) {
        return storage;
      }
      
      // 检查外部存储权限
      var externalStorage = await Permission.manageExternalStorage.status;
      if (externalStorage.isGranted) {
        return externalStorage;
      }
      
      // 检查媒体权限（Android 13+）
      var photos = await Permission.photos.status;
      if (photos.isGranted) {
        return photos;
      }
      
      // 返回最相关的权限状态
      return storage;
    } else if (Platform.isIOS) {
      return await Permission.photos.status;
    }
    
    return PermissionStatus.denied;
  }
  
  /// 显示权限请求说明对话框
  static Future<bool> _showPermissionRequestDialog(
    BuildContext context,
    String permissionName,
    String description,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.security,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text('需要$permissionName'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '您可以随时在设置中修改权限',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              '拒绝',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('授予权限'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  /// 显示权限被永久拒绝的对话框
  static Future<bool> _showPermissionPermanentlyDeniedDialog(
    BuildContext context,
    String permissionName,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.warning,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text('$permissionName权限被拒绝'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '您之前已拒绝了$permissionName权限，需要在系统设置中手动开启。',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '操作步骤：',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1. 点击"去设置"按钮\n2. 找到"权限"或"应用权限"\n3. 开启$permissionName权限',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              '取消',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx, true);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('去设置'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  /// 请求通知权限
  static Future<bool> requestNotificationPermission([BuildContext? context]) async {
    if (context != null) {
      // 先检查权限状态
      final status = await Permission.notification.status;
      if (status.isGranted) {
        return true;
      }
      
      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          return await _showPermissionPermanentlyDeniedDialog(context, '通知');
        }
        return false;
      }
      
      // 显示权限请求说明对话框
      if (context.mounted) {
        final userWantsToGrant = await _showPermissionRequestDialog(
          context,
          '通知权限',
          '为了及时通知您重要信息，我们需要通知权限。\n\n• 版本更新通知\n• 重要系统消息\n• 操作完成提醒',
        );
        
        if (!userWantsToGrant) {
          return false;
        }
      }
    }
    
    final status = await Permission.notification.request();
    return status.isGranted;
  }
  
  /// 请求相机权限
  static Future<bool> requestCameraPermission([BuildContext? context]) async {
    if (context != null) {
      // 先检查权限状态
      final status = await Permission.camera.status;
      if (status.isGranted) {
        return true;
      }
      
      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          return await _showPermissionPermanentlyDeniedDialog(context, '相机');
        }
        return false;
      }
      
      // 显示权限请求说明对话框
      if (context.mounted) {
        final userWantsToGrant = await _showPermissionRequestDialog(
          context,
          '相机权限',
          '为了让您能够拍照和录制视频，我们需要相机权限。\n\n• 拍照功能\n• 录制视频\n• 扫描二维码',
        );
        
        if (!userWantsToGrant) {
          return false;
        }
      }
    }
    
    final status = await Permission.camera.request();
    
    if (status.isPermanentlyDenied && context != null && context.mounted) {
      await _showPermissionPermanentlyDeniedDialog(context, '相机');
      return false;
    }
    
    return status.isGranted;
  }
  
  /// 请求麦克风权限
  static Future<bool> requestMicrophonePermission([BuildContext? context]) async {
    if (context != null) {
      // 先检查权限状态
      final status = await Permission.microphone.status;
      if (status.isGranted) {
        return true;
      }
      
      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          return await _showPermissionPermanentlyDeniedDialog(context, '麦克风');
        }
        return false;
      }
      
      // 显示权限请求说明对话框
      if (context.mounted) {
        final userWantsToGrant = await _showPermissionRequestDialog(
          context,
          '麦克风权限',
          '为了让您能够录制音频和语音交互，我们需要麦克风权限。\n\n• 录制音频\n• 语音输入\n• 语音通话',
        );
        
        if (!userWantsToGrant) {
          return false;
        }
      }
    }
    
    final status = await Permission.microphone.request();
    
    if (status.isPermanentlyDenied && context != null && context.mounted) {
      await _showPermissionPermanentlyDeniedDialog(context, '麦克风');
      return false;
    }
    
    return status.isGranted;
  }
  
  /// 显示权限设置引导对话框（保持向后兼容）
  static Future<void> showPermissionSettingsDialog(BuildContext context, String permissionName) async {
    await _showPermissionPermanentlyDeniedDialog(context, permissionName);
  }

  /// 测试权限请求流程（仅用于开发测试）
  static Future<void> testPermissionFlow(BuildContext context) async {
    print('🧪 开始测试权限请求流程...');
    
    // 测试存储权限
    print('📁 测试存储权限请求...');
    final storageResult = await requestStoragePermission(context);
    print('📁 存储权限结果: $storageResult');
    
    // 测试通知权限
    print('🔔 测试通知权限请求...');
    final notificationResult = await requestNotificationPermission(context);
    print('🔔 通知权限结果: $notificationResult');
    
    // 测试相机权限
    print('📷 测试相机权限请求...');
    final cameraResult = await requestCameraPermission(context);
    print('📷 相机权限结果: $cameraResult');
    
    // 测试麦克风权限
    print('🎤 测试麦克风权限请求...');
    final microphoneResult = await requestMicrophonePermission(context);
    print('🎤 麦克风权限结果: $microphoneResult');
    
    print('🧪 权限测试完成！');
    print('📊 测试结果汇总:');
    print('  - 存储权限: $storageResult');
    print('  - 通知权限: $notificationResult');
    print('  - 相机权限: $cameraResult');
    print('  - 麦克风权限: $microphoneResult');
  }
} 