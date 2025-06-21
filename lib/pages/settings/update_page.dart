import 'package:flutter/material.dart';
import 'package:safe_app/services/update_service.dart';
import 'package:safe_app/utils/toast_util.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({Key? key}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  bool _isChecking = false;
  bool _isDownloading = false;
  bool _isInstalling = false;
  double _downloadProgress = 0.0;
  Map<String, dynamic>? _updateInfo;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  // 检查更新
  Future<void> _checkUpdate() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      final updateInfo = await UpdateService().checkUpdate();

      setState(() {
        _isChecking = false;
        _updateInfo = updateInfo;
        if (updateInfo == null) {
          _errorMessage = '当前已是最新版本';
        }
      });
    } catch (e) {
      setState(() {
        _isChecking = false;
        _errorMessage = '检查更新失败: $e';
      });
    }
  }

  // 下载并安装更新
  Future<void> _downloadAndInstall() async {
    if (_updateInfo == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _errorMessage = null;
    });

    try {
      // 获取文件信息
      final fileUuid = _updateInfo!['uuid'];
      final filename = _updateInfo!['filename'];

      if (fileUuid == null || filename == null) {
        setState(() {
          _isDownloading = false;
          _errorMessage = '更新信息不完整';
        });
        return;
      }

      // 下载更新文件
      final filePath = await UpdateService().downloadUpdate(fileUuid, filename,
          onProgress: (progress) {
        setState(() {
          _downloadProgress = progress;
        });
      });

      if (filePath == null) {
        setState(() {
          _isDownloading = false;
          _errorMessage = '下载更新文件失败';
        });
        return;
      }

      setState(() {
        _isDownloading = false;
        _isInstalling = true;
      });

      // 安装更新
      final success = await UpdateService().installUpdate(filePath);

      setState(() {
        _isInstalling = false;
      });

      if (success) {
        ToastUtil.showShort('更新安装成功，请重启应用');
      } else {
        setState(() {
          _errorMessage = '安装更新失败';
        });
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _isInstalling = false;
        _errorMessage = '更新过程出错: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('应用更新'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isChecking)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在检查更新...'),
                  ],
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_errorMessage!,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _checkUpdate,
                      child: const Text('重新检查'),
                    ),
                  ],
                ),
              )
            else if (_updateInfo != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '发现新版本',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('当前版本号: ${_updateInfo!['version'] ?? '未知'}'),
                  Text('版本号: ${_updateInfo!['version'] ?? '未知'}'),
                  const SizedBox(height: 8),
                  const Text('更新内容:'),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_updateInfo!['changelog'] ?? '暂无更新说明'),
                  ),
                  const SizedBox(height: 24),
                  if (_isDownloading)
                    Column(
                      children: [
                        LinearProgressIndicator(value: _downloadProgress),
                        const SizedBox(height: 8),
                        Text(
                            '下载中... ${(_downloadProgress * 100).toStringAsFixed(1)}%'),
                      ],
                    )
                  else if (_isInstalling)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('正在安装更新...'),
                      ],
                    )
                  else
                    ElevatedButton(
                      onPressed: _downloadAndInstall,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('下载并安装更新'),
                    ),
                ],
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 48, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text('当前已是最新版本'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _checkUpdate,
                      child: const Text('重新检查'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
