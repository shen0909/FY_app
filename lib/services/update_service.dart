import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:version/version.dart';

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

  /// 下载更新文件
  Future<String?> downloadUpdate(String fileUuid, String filename,{Function(double)? onProgress}) async {
    try {
      // 创建临时目录用于存储下载的文件块
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/update_temp';
      Directory(tempPath).createSync(recursive: true);
      
      // 下载文件块的索引
      int fileIndex = 0;
      // 是否完成下载
      bool isFinished = false;
      // 总块数
      int totalChunks = 0;
      // 文件块列表
      List<String> fileChunks = [];
      
      // 循环下载所有文件块
      while (!isFinished) {
        final chunkResult = await ApiService().downloadUpdateFile(fileUuid, fileIndex);
        
        if (chunkResult == null) {
          if (kDebugMode) {
            print('$_tag 下载文件块失败: index=$fileIndex');
          }
          return null;
        }
        
        // 获取文件块数据
        final base64Data = chunkResult['file_base64'];
        if (base64Data == null || base64Data.isEmpty) {
          if (kDebugMode) {
            print('$_tag 文件块数据为空: index=$fileIndex');
          }
          return null;
        }
        
        // 保存文件块
        String chunkPath = '$tempPath/chunk_$fileIndex';
        File chunkFile = File(chunkPath);
        await chunkFile.writeAsBytes(base64Decode(base64Data));
        fileChunks.add(chunkPath);
        
        // 更新状态
        totalChunks = chunkResult['total_chunks'] ?? 0;
        isFinished = chunkResult['is_finish'] ?? false;
        fileIndex++;

        // 下载进度回调
        if (onProgress != null && totalChunks > 0) {
          double progress = fileIndex / totalChunks;
          onProgress(progress);
        }

        // 打印进度
        if (kDebugMode) {
          print('$_tag 下载进度: ${chunkResult['progress'] ?? '未知'}');
        }
      }
      
      if (kDebugMode) {
        print('$_tag 文件块下载完成，开始合并文件');
      }
      
      // 合并文件块
      String outputPath = '${tempDir.path}/$filename';
      File outputFile = File(outputPath);
      if (outputFile.existsSync()) {
        outputFile.deleteSync();
      }
      
      // 创建文件并写入数据
      IOSink sink = outputFile.openWrite(mode: FileMode.writeOnlyAppend);
      for (String chunkPath in fileChunks) {
        File chunkFile = File(chunkPath);
        sink.add(await chunkFile.readAsBytes());
        // 删除临时文件块
        chunkFile.deleteSync();
      }
      await sink.flush();
      await sink.close();
      
      // 清理临时目录
      Directory(tempPath).deleteSync(recursive: true);
      
      if (kDebugMode) {
        print('$_tag 更新文件下载完成: $outputPath');
      }
      
      return outputPath;
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
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 安装更新异常: $e');
      }
      return false;
    }
  }
} 