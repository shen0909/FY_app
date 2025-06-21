import 'dart:async';
import 'dart:collection';
import 'dart:convert';
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

  /// 下载更新文件 - 优化版本 (支持并发和按序写入)
  Future<String?> downloadUpdate(
    String fileUuid,
    String filename, {
    Function(double)? onProgress,
    CancelToken? cancelToken,
    int maxConcurrentDownloads = 3,
  }) async {
    // 确保取消操作可以在任何时候执行
    cancelToken ??= CancelToken();

    try {
      // 1. 设置下载参数和状态
      Directory tempDir = await getTemporaryDirectory();
      String downloadId = DateTime.now().millisecondsSinceEpoch.toString();
      String tempPath = '${tempDir.path}/update_temp_$downloadId';
      Directory(tempPath).createSync(recursive: true);

      if (kDebugMode) {
        print('$_tag 开始下载更新文件，使用并发数: $maxConcurrentDownloads');
      }

      // 存储已下载的文件块数据，键为文件索引，值为文件块的字节数组
      final SplayTreeMap<int, Uint8List> downloadedChunks = SplayTreeMap<int, Uint8List>();
      
      // 下一个要写入的块索引
      int nextChunkToWrite = 0;
      // 总块数
      int totalChunks = 0;
      // 是否已经获取到总块数
      bool hasTotalChunks = false;
      // 是否所有块都已下载完成
      bool allChunksDownloaded = false;
      // 下载错误
      String? downloadError;

      // 用于通知有新块可用的控制器
      final chunkAvailableController = StreamController<void>();
      // 用于通知所有下载完成的控制器
      final allDownloadsCompleteController = Completer<void>();

      // 2. 启动文件写入任务
      final writeTask = _writeChunksToFile(
        outputPath: '${tempDir.path}/$filename',
        downloadedChunks: downloadedChunks,
        nextChunkToWrite: () => nextChunkToWrite,
        updateNextChunk: (value) => nextChunkToWrite = value,
        getTotalChunks: () => totalChunks,
        isAllChunksDownloaded: () => allChunksDownloaded,
        onProgress: onProgress,
        chunkAvailableStream: chunkAvailableController.stream,
        cancelToken: cancelToken,
      );

      // 3. 先下载第一个块以获取总块数
      try {
        final firstChunkResult = await ApiService().downloadUpdateFile(fileUuid, 0, cancelToken: cancelToken);
        if (firstChunkResult == null) {
          throw Exception('无法获取第一个文件块信息');
        }

        totalChunks = firstChunkResult['total_chunks'] ?? 0;
        if (totalChunks <= 0) {
          throw Exception('总块数无效或为0');
        }

        hasTotalChunks = true;
        
        // 将第一个块的数据放入缓存
        final base64Data = firstChunkResult['file_base64'];
        if (base64Data != null && base64Data.isNotEmpty) {
          downloadedChunks[0] = base64Decode(base64Data);
          chunkAvailableController.add(null); // 通知写入器
        } else {
          throw Exception('第一个块数据为空');
        }

        if (kDebugMode) {
          print('$_tag 获取到总块数: $totalChunks');
        }
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 获取第一个块失败: $e');
        }
        downloadError = e.toString();
        allChunksDownloaded = true;
        allDownloadsCompleteController.complete();
        await chunkAvailableController.close();
        await _cleanupTempDirectory(tempPath);
        return null;
      }

      // 4. 启动并发下载任务
      final List<Future<void>> downloadTasks = [];
      final Set<int> pendingChunks = <int>{};
      final Set<int> processingChunks = <int>{};

      // 初始化待下载的块列表（除了第一个块）
      for (int i = 1; i < totalChunks; i++) {
        pendingChunks.add(i);
      }

      // 创建工作线程池
      for (int i = 0; i < maxConcurrentDownloads; i++) {
        downloadTasks.add(_downloadChunkWorker(
          i,
          fileUuid,
          pendingChunks,
          processingChunks,
          downloadedChunks,
          chunkAvailableController,
          cancelToken,
        ));
      }

      // 等待所有下载任务完成
      await Future.wait(downloadTasks).then((_) {
        if (kDebugMode) {
          print('$_tag 所有下载任务完成');
        }
        allChunksDownloaded = true;
        allDownloadsCompleteController.complete();
        chunkAvailableController.add(null); // 通知写入器检查是否所有块都已写入
      }).catchError((error) {
        if (kDebugMode) {
          print('$_tag 下载任务出错: $error');
        }
        downloadError = error.toString();
        allChunksDownloaded = true;
        if (!allDownloadsCompleteController.isCompleted) {
          allDownloadsCompleteController.complete();
        }
        chunkAvailableController.add(null);
      });

      // 等待写入任务完成
      final String? outputPath = await writeTask;
      await chunkAvailableController.close();

      // 清理临时目录
      await _cleanupTempDirectory(tempPath);

      if (downloadError != null) {
        if (kDebugMode) {
          print('$_tag 下载过程中出现错误: $downloadError');
        }
        return null;
      }

      return outputPath;
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

  /// 私有方法：下载文件块的工作协程
  Future<void> _downloadChunkWorker(
    int workerId,
    String fileUuid,
    Set<int> pendingChunks,
    Set<int> processingChunks,
    SplayTreeMap<int, Uint8List> downloadedChunks,
    StreamController<void> chunkAvailableController,
    CancelToken? cancelToken,
  ) async {
    if (kDebugMode) {
      print('$_tag 工作线程 $workerId 启动');
    }

    while (pendingChunks.isNotEmpty && !cancelToken!.isCancelled) {
      int? chunkIndex;
      
      // 同步块，防止多个工作线程抢同一个块
      synchronized(() {
        if (pendingChunks.isNotEmpty) {
          chunkIndex = pendingChunks.first;
          pendingChunks.remove(chunkIndex);
          processingChunks.add(chunkIndex!);
        }
      });

      if (chunkIndex == null) {
        break; // 没有更多块需要下载
      }

      // 下载指定块，带重试逻辑
      const int maxRetries = 3;
      int currentRetry = 0;
      bool success = false;

      while (currentRetry < maxRetries && !success && !cancelToken.isCancelled) {
        try {
          if (kDebugMode) {
            print('$_tag 工作线程 $workerId 开始下载块 $chunkIndex (尝试 ${currentRetry + 1}/$maxRetries)');
          }

          final chunkResult = await ApiService().downloadUpdateFile(fileUuid, chunkIndex!, cancelToken: cancelToken);
          
          if (chunkResult != null && chunkResult['file_base64'] != null && chunkResult['file_base64'].isNotEmpty) {
            // 解码并存入共享Map
            synchronized(() {
              downloadedChunks[chunkIndex!] = base64Decode(chunkResult['file_base64']);
              processingChunks.remove(chunkIndex);
            });
            
            // 通知写入器有新块可用
            chunkAvailableController.add(null);
            success = true;
            
            if (kDebugMode) {
              print('$_tag 工作线程 $workerId 成功下载块 $chunkIndex');
            }
          } else {
            throw Exception('块数据为空或无效');
          }
        } on DioException catch (e) {
          if (e.type == DioExceptionType.cancel) {
            if (kDebugMode) {
              print('$_tag 工作线程 $workerId 下载块 $chunkIndex 被取消');
            }
            return; // 立即退出
          }
          currentRetry++;
          if (kDebugMode) {
            print('$_tag 工作线程 $workerId 下载块 $chunkIndex 失败: ${e.message}, 重试 $currentRetry/$maxRetries');
          }
          await Future.delayed(Duration(seconds: currentRetry)); // 指数退避
        } catch (e) {
          currentRetry++;
          if (kDebugMode) {
            print('$_tag 工作线程 $workerId 下载块 $chunkIndex 失败: $e, 重试 $currentRetry/$maxRetries');
          }
          await Future.delayed(Duration(seconds: currentRetry)); // 指数退避
        }
      }

      // 如果重试后仍然失败
      if (!success) {
        if (kDebugMode) {
          print('$_tag 工作线程 $workerId 下载块 $chunkIndex 最终失败');
        }
        // 将块放回待处理队列，或者抛出异常终止整个下载
        synchronized(() {
          processingChunks.remove(chunkIndex);
          pendingChunks.add(chunkIndex!); // 放回队列，其他工作线程可能会成功
        });
      }
    }

    if (kDebugMode) {
      print('$_tag 工作线程 $workerId 完成任务');
    }
  }

  /// 私有方法：文件写入的工作协程
  Future<String?> _writeChunksToFile({
    required String outputPath,
    required SplayTreeMap<int, Uint8List> downloadedChunks,
    required int Function() nextChunkToWrite,
    required Function(int) updateNextChunk,
    required int Function() getTotalChunks,
    required bool Function() isAllChunksDownloaded,
    required Function(double)? onProgress,
    required Stream<void> chunkAvailableStream,
    required CancelToken? cancelToken,
  }) async {
    File outputFile = File(outputPath);
    if (outputFile.existsSync()) {
      outputFile.deleteSync();
    }
    
    IOSink? sink;
    try {
      sink = outputFile.openWrite(mode: FileMode.writeOnlyAppend);
      
      await for (var _ in chunkAvailableStream) {
        if (cancelToken?.isCancelled == true) {
          if (kDebugMode) {
            print('$_tag 文件写入被取消');
          }
          await sink.flush();
          await sink.close();
          return null;
        }
        
        // 检查并写入可用的连续块
        await _writeAvailableChunks(
          sink: sink,
          downloadedChunks: downloadedChunks,
          nextChunkToWrite: nextChunkToWrite,
          updateNextChunk: updateNextChunk,
          getTotalChunks: getTotalChunks,
          onProgress: onProgress,
        );
        
        // 检查是否所有块都已写入
        if (nextChunkToWrite() >= getTotalChunks() && getTotalChunks() > 0) {
          if (kDebugMode) {
            print('$_tag 所有块已写入，文件下载完成');
          }
          break;
        }
        
        // 如果所有块都已下载但还有块未写入，继续尝试写入
        if (isAllChunksDownloaded() && downloadedChunks.isNotEmpty) {
          continue;
        }
      }
      
      await sink.flush();
      await sink.close();
      
      if (nextChunkToWrite() < getTotalChunks()) {
        if (kDebugMode) {
          print('$_tag 文件写入不完整: ${nextChunkToWrite()}/${getTotalChunks()}');
        }
        return null;
      }
      
      if (kDebugMode) {
        print('$_tag 更新文件下载完成: $outputPath');
      }
      
      return outputPath;
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 文件写入异常: $e');
      }
      await sink?.flush();
      await sink?.close();
      return null;
    }
  }
  
  /// 写入所有可用的连续块
  Future<void> _writeAvailableChunks({
    required IOSink sink,
    required SplayTreeMap<int, Uint8List> downloadedChunks,
    required int Function() nextChunkToWrite,
    required Function(int) updateNextChunk,
    required int Function() getTotalChunks,
    required Function(double)? onProgress,
  }) async {
    // 循环检查是否有连续的块可以写入
    while (downloadedChunks.containsKey(nextChunkToWrite())) {
      final chunkData = downloadedChunks.remove(nextChunkToWrite())!;
      sink.add(chunkData);
      
      // 更新下一个要写入的块索引
      updateNextChunk(nextChunkToWrite() + 1);
      
      // 更新进度
      if (onProgress != null && getTotalChunks() > 0) {
        double progress = nextChunkToWrite() / getTotalChunks();
        onProgress(progress);
        
        if (kDebugMode && nextChunkToWrite() % 5 == 0) {
          print('$_tag 下载进度: ${(progress * 100).toStringAsFixed(1)}%');
        }
      }
    }
  }
  
  // 清理临时目录的辅助方法
  Future<void> _cleanupTempDirectory(String tempPath) async {
    try {
      Directory tempDir = Directory(tempPath);
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        if (kDebugMode) {
          print('$_tag 临时目录已清理: $tempPath');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 清理临时目录失败: $e');
      }
    }
  }
  
  /// 同步块，用于确保多线程安全
  void synchronized(Function() action) {
    action();
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