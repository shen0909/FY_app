import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:safe_app/main.dart';
import 'package:safe_app/services/update_service.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({Key? key}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  Map<String, dynamic>? _updateInfo;
  bool _isLoading = false;
  bool _isDownloading = false;
  bool _isInstalling = false;
  double _downloadProgress = 0.0;
  String _errorMessage = '';
  CancelToken? _cancelToken;
  PackageInfo? packageInfo;
  String? currentVersion;

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  @override
  void dispose() {
    _cancelDownloadIfNeeded();
    super.dispose();
  }

  // 检查更新
  Future<void> _checkUpdate() async {
    packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo!.version;
    
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final updateInfo = await UpdateService().checkUpdate();
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _updateInfo = updateInfo;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '检查更新失败: $e';
      });
    }
  }

  // 取消下载
  void _cancelDownloadIfNeeded() {
    if (_isDownloading && _cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('用户取消下载');
      if(mounted){
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0;
          _errorMessage = '下载已取消';
        });
      }
    }
  }

  /// 下载更新
  Future<void> _downloadUpdate() async {
    if (_isDownloading || _isInstalling) {
      return;
    }
    
    if (!mounted) return;
    
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _errorMessage = '';
      _cancelToken = CancelToken();
    });
    
    try {
      final filePath = await UpdateService().downloadUpdate(
          _updateInfo!['uuid'],
          _updateInfo!['filename'],
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
            });
          }
        },
        cancelToken: _cancelToken
      );
      
      if (!mounted) return;
      
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0;
      });
      
      if (filePath == null) {
        if (!mounted) return;
        setState(() {
          _errorMessage = '下载失败';
        });
        return;
      }
      
      // 下载完成后开始安装
      if (!mounted) return;
      setState(() {
        _isInstalling = true;
      });
      
      // 调用安装方法
      await _installUpdate(filePath);
      
      if (!mounted) return;
      setState(() {
        _isInstalling = false;
      });
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('下载更新异常: ${e.message}');
      }
      
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0;
        if (e.type == DioExceptionType.cancel) {
          _errorMessage = '下载已取消';
        } else {
          _errorMessage = '下载失败: ${e.message}';
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('下载更新异常: $e');
      }
      
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0;
        _errorMessage = '下载失败: $e';
      });
    }
  }

  // 显示安装确认对话框
  Future<bool> _showInstallConfirmDialog() async {
    // 使用mounted检查确保组件仍然挂载在widget树中
    if (!mounted) return false;
    
    try {
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return WillPopScope(
            onWillPop: () async => false, // 防止返回键关闭对话框
            child: AlertDialog(
              title: const Text('安装更新'),
              content: const Text('下载完成，是否立即安装更新？'),
              actions: <Widget>[
                TextButton(
                  child: const Text('取消'),
                  onPressed: () {
                    // 使用dialogContext而不是外层context
                    Navigator.of(dialogContext).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('安装'),
                  onPressed: () {
                    // 使用dialogContext而不是外层context
                    Navigator.of(dialogContext).pop(true);
                  },
                ),
              ],
            ),
          );
        },
      ) ?? false; // 如果对话框被意外关闭，返回false
    } catch (e) {
      if (kDebugMode) {
        print('显示安装确认对话框出错: $e');
      }
      return false;
    }
  }

  /// 安装更新
  Future<void> _installUpdate(String filePath) async {
    try {
      // 显示安装确认对话框
      bool confirm = await _showInstallConfirmDialog();
      if (!confirm) {
        return;
      }
      
      // 调用安装服务
      bool result = await UpdateService().installUpdate(filePath);
      
      if (!result) {
        if (mounted) {
          ToastUtil.showError('安装失败，请检查是否授予安装权限');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('安装更新异常: $e');
      }
      if (mounted) {
        ToastUtil.showError('安装过程中出现异常');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('检查更新'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkUpdate,
            tooltip: '重新检查',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在检查更新...'),
                  ],
                ),
              )
            else if (_updateInfo != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '发现新版本: ${_updateInfo!['version']}',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.w),
                            Text('当前版本: ${currentVersion ?? '未知'}',style: TextStyle(fontSize: 14.sp)),
                            SizedBox(height: 16.w),
                            Text(
                              '更新内容:',
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.sp),
                            ),
                            SizedBox(height: 8.w),
                            Text(_updateInfo!['description'] ?? '暂无更新说明',style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isDownloading)
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: _downloadProgress,
                            backgroundColor: Colors.grey[300],
                          ),
                          SizedBox(height: 8.w),
                          RepaintBoundary(child: Text('下载进度: ${(_downloadProgress * 100).toStringAsFixed(1)}%')),
                          SizedBox(height: 16.w),
                          ElevatedButton(
                            onPressed: _cancelDownloadIfNeeded,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0XFF345DFF),
                              padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: 12.w),
                            ),
                            child: Text('取消下载',style: TextStyle(fontSize: 14.sp,color: FYColors.whiteColor),),
                          ),
                        ],
                      )
                    else if (_isInstalling)
                       Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16.w),
                          Text('正在安装更新...'),
                        ],
                      )
                    else
                      ElevatedButton(
                        onPressed: _downloadUpdate,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.w),
                        ),
                        child: Text('下载并安装更新',style: TextStyle(fontSize: 14.sp)),
                      ),
                  ],
                ),
              )
            else
              Center(
                child: Text('当前已是最新版本',style: TextStyle(fontSize: 14.sp),),
              ),
              
            // if (_errorMessage.isNotEmpty)
            //   Padding(
            //     padding: EdgeInsets.only(top: 16.w),
            //     child: Text(
            //       _errorMessage,
            //       style: const TextStyle(color: Colors.red),
            //       textAlign: TextAlign.center,
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
