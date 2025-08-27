# 文档预览功能

## 功能概述

这是一个完整的应用内文档预览解决方案，支持多种文档格式的在线预览，无需跳转外部应用。

## 支持格式

- **PDF文档** (.pdf) - 应用内直接预览
- **Word文档** (.doc, .docx) - 使用Office Online预览
- **Excel表格** (.xls, .xlsx) - 使用Office Online预览  
- **PowerPoint演示** (.ppt, .pptx) - 使用Office Online预览
- **其他格式** - WebView通用预览

## 核心特性

### 1. 应用内预览
- 使用WebView技术，文档在应用内显示
- 支持缩放、翻页、导航等操作
- 全屏预览模式

### 2. 智能预览策略
- 根据文档类型自动选择最佳预览方式
- PDF文件下载到本地后应用内预览
- Office文档使用Office Online服务预览

### 3. 用户体验优化
- 加载进度显示
- 错误处理和重试机制
- 预览模式切换（应用内/外部）
- 下载和分享功能

### 4. 工具栏功能
- 缩放控制（放大/缩小/重置）
- 导航控制（前进/后退）
- 全屏切换
- 刷新预览

## 使用方法

### 1. 基本使用

```dart
// 跳转到文档预览页面
Get.toNamed('/document_preview', arguments: {
  'documentUrl': 'https://example.com/document.pdf',
  'documentTitle': '示例文档',
  'documentType': 'PDF文档',
});
```

### 2. 在订单事件详情页面使用

```dart
// 预览报告
void previewReport() async {
  final link = state.reportInfo['download_link']?.toString() ?? '';
  if (link.isEmpty) {
    Get.snackbar('提示', '暂无可预览的报告链接');
    return;
  }
  
  // 获取文件名
  String fileName = (state.reportInfo['file_name']?.toString() ?? '').trim();
  if (fileName.isEmpty) {
    final uri = Uri.parse(link);
    fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '报告.docx';
  }
  
  // 跳转到应用内预览页面
  Get.toNamed('/document_preview', arguments: {
    'documentUrl': link,
    'documentTitle': fileName,
    'documentType': fileName,
  });
}
```

### 3. 路由配置

在 `lib/routers/routers.dart` 中添加：

```dart
static const String documentPreview = '/document_preview';

// 在pages列表中添加
GetPage(name: documentPreview, page: () => DocumentPreviewView()),
```

## 技术实现

### 1. 架构设计
- **状态管理**: 使用GetX进行状态管理
- **业务逻辑**: 分离逻辑和视图，便于维护
- **错误处理**: 完善的异常处理机制

### 2. 核心组件
- `DocumentPreviewState`: 状态管理类
- `DocumentPreviewLogic`: 业务逻辑类
- `DocumentPreviewView`: UI视图类

### 3. 关键技术
- **WebView**: 使用 `webview_flutter` 插件
- **文件下载**: 使用 `dio` 进行文件下载
- **Office预览**: 集成Office Online服务
- **本地存储**: 使用 `path_provider` 管理临时文件

## 配置要求

### 1. 依赖配置

确保 `pubspec.yaml` 包含以下依赖：

```yaml
dependencies:
  webview_flutter: ^4.10.0
  dio: ^5.6.0
  path_provider: ^2.1.5
  get: ^4.6.6
  flutter_screenutil: ^5.9.3
```

### 2. 权限配置

#### Android权限
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### iOS权限
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 自定义配置

### 1. 修改预览策略

在 `DocumentPreviewLogic` 中修改 `_checkPreviewSupport` 方法：

```dart
void _checkPreviewSupport() {
  // 自定义支持的格式
  final supportedFormats = ['.pdf', '.doc', '.docx', '.custom'];
  // ... 其他逻辑
}
```

### 2. 修改UI样式

在 `DocumentPreviewView` 中修改样式配置：

```dart
// 修改主题色
final primaryColor = Colors.blue[600]!;

// 修改字体大小
final titleFontSize = 18.sp;
```

### 3. 添加新的预览方式

在 `DocumentPreviewLogic` 中添加新的预览方法：

```dart
Future<void> _previewCustomFormat(String url) async {
  // 自定义预览逻辑
}
```

## 性能优化

### 1. 内存管理
- 及时释放WebView资源
- 清理临时下载文件
- 使用懒加载策略

### 2. 网络优化
- 支持断点续传
- 文件缓存机制
- 压缩传输

### 3. 用户体验
- 预加载机制
- 后台下载
- 离线预览支持

## 故障排除

### 1. 常见问题

**WebView无法加载**
- 检查网络权限
- 确认URL格式正确
- 查看控制台错误信息

**Office文档预览失败**
- 检查Office Online服务可用性
- 确认文档URL可访问
- 尝试切换到外部预览

**PDF预览异常**
- 检查PDF文件完整性
- 确认本地存储权限
- 查看文件下载状态

### 2. 调试方法

```dart
// 启用详细日志
void _enableDebugMode() {
  print('Document URL: ${state.documentUrl.value}');
  print('Document Type: ${state.documentType.value}');
  print('Preview Mode: ${state.previewMode.value}');
}
```

## 更新日志

### v1.0.0 (2024-01-XX)
- 初始版本发布
- 支持PDF、Word、Excel、PowerPoint预览
- 应用内预览和外部预览切换
- 完整的工具栏功能

## 贡献指南

欢迎提交Issue和Pull Request来改进这个功能。

## 许可证

本项目采用MIT许可证。 