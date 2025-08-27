import 'package:get/get.dart';

class DocumentPreviewState {
  // 文档URL
  final RxString documentUrl = ''.obs;
  
  // 文档标题
  final RxString documentTitle = '文档预览'.obs;
  
  // 文档类型
  final RxString documentType = ''.obs;
  
  // 是否正在加载
  final RxBool isLoading = false.obs;
  
  // 是否加载失败
  final RxBool isError = false.obs;
  
  // 错误信息
  final RxString errorMessage = ''.obs;
  
  // 下载进度 (0.0 - 1.0)
  final RxDouble downloadProgress = 0.0.obs;
  
  // 是否支持应用内预览
  final RxBool supportsInAppPreview = true.obs;
  
  // 预览方式：'in_app' 或 'external'
  final RxString previewMode = 'in_app'.obs;
  
  // WebView控制器
  final RxBool webViewReady = false.obs;
  
  // 是否显示工具栏
  final RxBool showToolbar = true.obs;
  
  // 是否全屏模式
  final RxBool isFullScreen = false.obs;
  
  // 缩放级别
  final RxDouble zoomLevel = 1.0.obs;
  
  // 本地文件路径（如果已下载）
  final RxString localFilePath = ''.obs;
  
  // 文件大小
  final RxString fileSize = ''.obs;
  
  // 最后修改时间
  final RxString lastModified = ''.obs;
  
  DocumentPreviewState();
  
  // 重置状态
  void reset() {
    isLoading.value = false;
    isError.value = false;
    errorMessage.value = '';
    downloadProgress.value = 0.0;
    webViewReady.value = false;
    showToolbar.value = true;
    isFullScreen.value = false;
    zoomLevel.value = 1.0;
    localFilePath.value = '';
    fileSize.value = '';
    lastModified.value = '';
  }
  
  // 设置加载状态
  void setLoading(bool loading) {
    isLoading.value = loading;
    if (loading) {
      isError.value = false;
      errorMessage.value = '';
    }
  }
  
  // 设置错误状态
  void setError(String message) {
    isError.value = true;
    errorMessage.value = message;
    isLoading.value = false;
  }
  
  // 设置下载进度
  void setDownloadProgress(double progress) {
    downloadProgress.value = progress.clamp(0.0, 1.0);
  }
  
  // 切换全屏模式
  void toggleFullScreen() {
    isFullScreen.value = !isFullScreen.value;
    showToolbar.value = !isFullScreen.value;
  }
  
  // 设置缩放级别
  void setZoomLevel(double zoom) {
    zoomLevel.value = zoom.clamp(0.5, 3.0);
  }
} 