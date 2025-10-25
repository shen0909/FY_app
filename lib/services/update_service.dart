import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:version/version.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  static const String _tag = 'UpdateService';

  factory UpdateService() => _instance;

  UpdateService._internal();

  /// 检查更新
  Future<Map<String, dynamic>?> checkUpdate() async {
    try {
      // 调用API检查更新
      final updateInfo = await ApiService().checkAppVersion();
      
      if (updateInfo == null) {
        if (kDebugMode) {
          print('$_tag 获取更新信息失败');
        }
        return null;
      }
      
      // 获取当前应用版本
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      
      // 服务器返回的版本号
      String serverVersion = updateInfo['version'] ?? '0.0.0';
      
      // 比较版本号
      if (Version.parse(serverVersion) > Version.parse(currentVersion)) {
        if (kDebugMode) {
          print('$_tag 发现新版本: $serverVersion, 当前版本: $currentVersion');
        }
        return updateInfo;
      } else {
        if (kDebugMode) {
          print('$_tag 当前已是最新版本');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 检查更新异常: $e');
      }
      return null;
    }
  }

  /// 下载更新文件 - 简化版本 (直接下载)
  Future<String?> downloadUpdate(
    String fileUuid,
    String filename, {
    Function(double)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // 确保取消操作可以在任何时候执行
    cancelToken ??= CancelToken();

    try {
      if (kDebugMode) {
        print('$_tag 开始下载更新文件: $filename');
      }

      // 1. 获取下载链接
      String? downloadUrl = await ApiService().getUpdateDownloadUrl(fileUuid, cancelToken: cancelToken);
      if (downloadUrl == null || downloadUrl.isEmpty) {
        if (kDebugMode) {
          print('$_tag 获取下载链接失败');
        }
        return null;
      }

      if (kDebugMode) {
        print('$_tag 获取到下载链接: $downloadUrl');
      }

      // 2. 设置下载路径
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/$filename';

      // 3. 使用Dio直接下载文件
      Dio dio = Dio();
      
      // 设置下载选项
      Options options = Options(
        responseType: ResponseType.stream,
        followRedirects: true,
        validateStatus: (status) => status! < 500,
      );

      // 开始下载
      Response response = await dio.download(
        downloadUrl,
        filePath,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            double progress = received / total;
            onProgress(progress);
          }
        },
      );

      // 检查下载是否成功
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('$_tag 下载完成，文件路径: $filePath');
        }
        return filePath;
      } else {
        if (kDebugMode) {
          print('$_tag 下载失败，状态码: ${response.statusCode}');
        }
        return null;
      }

    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        if (kDebugMode) {
          print('$_tag 下载操作被取消');
        }
      } else {
        if (kDebugMode) {
          print('$_tag 下载更新异常: ${e.message}');
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 下载更新异常: $e');
      }
      return null;
    }
  }


  /// 安装更新
  Future<bool> installUpdate(String filePath) async {
    try {
      if (kDebugMode) {
        print('$_tag 开始安装更新: $filePath');
      }
      
      // 检查文件是否存在
      final file = File(filePath);
      if (!await file.exists()) {
        if (kDebugMode) {
          print('$_tag 安装文件不存在: $filePath');
        }
        return false;
      }
      
      // 获取文件扩展名
      final fileExt = filePath.split('.').last.toLowerCase();
      
      // 如果是APK文件，直接调用系统安装
      if (fileExt == 'apk') {
        if (Platform.isAndroid) {
          try {
            // 检查安装应用权限
            if (await _requestInstallPermission()) {
              // 使用open_file插件打开APK文件，系统会自动调用安装器
              final result = await OpenFile.open(filePath);
              if (kDebugMode) {
                print('$_tag 调用系统安装器结果: ${result.message}');
              }
              return result.type == ResultType.done;
            } else {
              if (kDebugMode) {
                print('$_tag 用户拒绝了安装权限');
              }
              return false;
            }
          } catch (e) {
            if (kDebugMode) {
              print('$_tag 调用系统安装器失败: $e');
            }
            return false;
          }
        } else {
          if (kDebugMode) {
            print('$_tag 当前平台不支持APK安装');
          }
          return false;
        }
      } 
      // 如果是ZIP文件，解压后作为热更新处理
      else if (fileExt == 'zip') {
        // 获取应用文档目录
        Directory appDir = await getApplicationDocumentsDirectory();
        String updateDir = '${appDir.path}/update';
        
        // 创建更新目录
        Directory(updateDir).createSync(recursive: true);
        
        // 解压更新文件
        final zipFile = File(filePath);
        final destinationDir = Directory(updateDir);
        
        try {
          await ZipFile.extractToDirectory(
            zipFile: zipFile, 
            destinationDir: destinationDir
          );
          
          if (kDebugMode) {
            print('$_tag 更新文件解压完成');
          }
          
          // TODO: 根据不同平台实现不同的热更新安装逻辑
          // Android: 可能需要调用原生方法加载新的资源
          // iOS: 可能需要重启应用或其他机制
          
          return true;
        } catch (e) {
          if (kDebugMode) {
            print('$_tag 解压更新文件失败: $e');
          }
          return false;
        }
      } else {
        if (kDebugMode) {
          print('$_tag 不支持的文件类型: $fileExt');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 安装更新异常: $e');
      }
      return false;
    }
  }
  
  /// 请求安装应用权限
  Future<bool> _requestInstallPermission() async {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        print('$_tag 请求安装未知来源应用权限');
      }
      
      // 检查是否已有权限
      final status = await Permission.requestInstallPackages.status;
      if (status.isGranted) {
        return true;
      }
      
      // 请求权限
      final result = await Permission.requestInstallPackages.request();
      return result.isGranted;
    }
    
    // 非Android平台默认返回true
    return true;
  }
} 