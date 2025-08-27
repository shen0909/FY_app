import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:async';
import 'document_preview_state.dart';

class DocumentPreviewLogic extends GetxController {
  final DocumentPreviewState state = DocumentPreviewState();
  final Dio _dio = Dio();
  
  WebViewController? webViewController;
  Timer? _progressTimer;
  
  @override
  void onReady() {
    super.onReady();
    _initializeFromArguments();
  }
  
  @override
  void onClose() {
    _progressTimer?.cancel();
    super.onClose();
  }
  
  // 从路由参数初始化
  void _initializeFromArguments() {
    final Map<String, dynamic>? args = Get.arguments;
    if (args != null) {
      if (args.containsKey('documentUrl')) {
        state.documentUrl.value = args['documentUrl'] as String;
      }
      if (args.containsKey('documentTitle')) {
        state.documentTitle.value = args['documentTitle'] as String;
      }
      if (args.containsKey('documentType')) {
        state.documentType.value = args['documentType'] as String;
      }
      
      // 根据文档类型判断是否支持应用内预览
      _checkPreviewSupport();
      
      // 开始加载文档
      _loadDocument();
    }
  }
  
  // 检查预览支持情况
  void _checkPreviewSupport() {
    final url = state.documentUrl.value.toLowerCase();
    final type = state.documentType.value.toLowerCase();
    
    // 支持应用内预览的格式
    final supportedFormats = ['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx'];
    final isSupported = supportedFormats.any((format) => url.contains(format) || type.contains(format));
    
    state.supportsInAppPreview.value = isSupported;
    
    // 如果不支持应用内预览，默认使用外部预览
    if (!isSupported) {
      state.previewMode.value = 'external';
    }
  }
  
  // 加载文档
  Future<void> _loadDocument() async {
    if (state.documentUrl.value.isEmpty) {
      state.setError('文档URL不能为空');
      return;
    }
    
    state.setLoading(true);
    
    try {
      if (state.previewMode.value == 'in_app') {
        await _loadInApp();
      } else {
        await _loadExternal();
      }
    } catch (e) {
      state.setError('加载文档失败: $e');
    }
  }
  
  // 应用内预览
  Future<void> _loadInApp() async {
    try {
      final url = state.documentUrl.value;
      final lower = url.toLowerCase();
      
      // 根据文件类型选择预览方式
      if (lower.endsWith('.pdf')) {
        await _previewPDFInApp(url);
      } else if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
        await _previewWordInApp(url);
      } else if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) {
        await _previewExcelInApp(url);
      } else if (lower.endsWith('.ppt') || lower.endsWith('.pptx')) {
        await _previewPowerPointInApp(url);
      } else {
        // 其他格式使用WebView预览
        await _previewInWebView(url);
      }
    } catch (e) {
      state.setError('应用内预览失败: $e');
    }
  }
  
  // PDF应用内预览
  Future<void> _previewPDFInApp(String url) async {
    try {
      // 下载PDF到本地临时目录
      final localPath = await _downloadDocument(url, 'document.pdf');
      state.localFilePath.value = localPath;
      
      // 使用WebView预览PDF
      final pdfUrl = 'file://$localPath';
      await _previewInWebView(pdfUrl);
      
      state.setLoading(false);
    } catch (e) {
      state.setError('PDF预览失败: $e');
    }
  }
  
  // Word文档应用内预览
  Future<void> _previewWordInApp(String url) async {
    try {
      // 使用Office Online预览Word文档
      final officeUrl = 'https://view.officeapps.live.com/op/view.aspx?src=${Uri.encodeComponent(url)}';
      await _previewInWebView(officeUrl);
      
      state.setLoading(false);
    } catch (e) {
      state.setError('Word文档预览失败: $e');
    }
  }
  
  // Excel应用内预览
  Future<void> _previewExcelInApp(String url) async {
    try {
      // 使用Office Online预览Excel文档
      final officeUrl = 'https://view.officeapps.live.com/op/view.aspx?src=${Uri.encodeComponent(url)}';
      await _previewInWebView(officeUrl);
      
      state.setLoading(false);
    } catch (e) {
      state.setError('Excel预览失败: $e');
    }
  }
  
  // PowerPoint应用内预览
  Future<void> _previewPowerPointInApp(String url) async {
    try {
      // 使用Office Online预览PowerPoint文档
      final officeUrl = 'https://view.officeapps.live.com/op/view.aspx?src=${Uri.encodeComponent(url)}';
      await _previewInWebView(officeUrl);
      
      state.setLoading(false);
    } catch (e) {
      state.setError('PowerPoint预览失败: $e');
    }
  }
  
  // WebView预览
  Future<void> _previewInWebView(String url) async {
    try {
      // 创建WebView控制器
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              state.setDownloadProgress(progress / 100);
            },
            onPageStarted: (String url) {
              state.setLoading(true);
            },
            onPageFinished: (String url) {
              state.setLoading(false);
              state.webViewReady.value = true;
            },
            onWebResourceError: (WebResourceError error) {
              state.setError('WebView加载失败: ${error.description}');
            },
          ),
        )
        ..loadRequest(Uri.parse(url));
        
      state.webViewReady.value = true;
    } catch (e) {
      state.setError('WebView初始化失败: $e');
    }
  }
  
  // 外部预览
  Future<void> _loadExternal() async {
    try {
      final url = state.documentUrl.value;
      final launched = await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        state.setLoading(false);
        Get.back(); // 返回上一页
      } else {
        state.setError('无法打开外部应用');
      }
    } catch (e) {
      state.setError('外部预览失败: $e');
    }
  }
  
  // 下载文档到本地
  Future<String> _downloadDocument(String url, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);
    
    // 如果文件已存在，先删除
    if (await file.exists()) {
      await file.delete();
    }
    
    // 下载文件
    await _dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          final progress = received / total;
          state.setDownloadProgress(progress);
        }
      },
    );
    
    // 获取文件信息
    final stat = await file.stat();
    state.fileSize.value = _formatFileSize(stat.size);
    state.lastModified.value = _formatDateTime(stat.modified);
    
    return filePath;
  }
  
  // 切换预览模式
  void togglePreviewMode() {
    if (state.previewMode.value == 'in_app') {
      state.previewMode.value = 'external';
      _loadExternal();
    } else {
      state.previewMode.value = 'in_app';
      _loadInApp();
    }
  }
  
  // 刷新预览
  void refreshPreview() {
    if (webViewController != null) {
      webViewController!.reload();
    }
  }
  
  // 返回上一页
  void goBack() {
    if (webViewController != null && state.webViewReady.value) {
      webViewController!.goBack();
    } else {
      Get.back();
    }
  }
  
  // 前进到下一页
  void goForward() {
    if (webViewController != null && state.webViewReady.value) {
      webViewController!.goForward();
    }
  }
  
  // // 缩放控制
  // void zoomIn() {
  //   final newZoom = state.zoomLevel.value + 0.2;
  //   state.setZoomLevel(newZoom);
  //   webViewController?.setZoomLevel(newZoom);
  // }
  //
  // void zoomOut() {
  //   final newZoom = state.zoomLevel.value - 0.2;
  //   state.setZoomLevel(newZoom);
  //   webViewController?.setZoomLevel(newZoom);
  // }
  //
  // void resetZoom() {
  //   state.setZoomLevel(1.0);
  //   webViewController?.setZoomLevel(1.0);
  // }
  //
  // 全屏切换
  void toggleFullScreen() {
    state.toggleFullScreen();
  }
  
  // 下载文档
  Future<void> downloadDocument() async {
    try {
      state.setLoading(true);
      final url = state.documentUrl.value;
      final fileName = _extractFileName(url);
      final localPath = await _downloadDocument(url, fileName);
      
      // 打开文件
      await OpenFile.open(localPath);
      
      Get.snackbar(
        '下载成功',
        '文档已下载到: $localPath',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      state.setError('下载失败: $e');
    } finally {
      state.setLoading(false);
    }
  }
  
  // 分享文档
  void shareDocument() {
    // 这里可以集成分享功能
    Get.snackbar('提示', '分享功能开发中...');
  }
  
  // 工具方法
  String _extractFileName(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      return pathSegments.last;
    }
    return 'document';
  }
  
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 