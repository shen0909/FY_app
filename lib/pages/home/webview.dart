import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FYWebView extends StatefulWidget {
  @override
  _FYWebViewState createState() => _FYWebViewState();
}

class _FYWebViewState extends State<FYWebView> {
  WebViewController? _controller;
  String? fileName;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  bool isControllerReady = false;

  @override
  void initState() {
    super.initState();
    print('FYWebView initState called');
    
    // 获取传入的参数
    final arguments = Get.arguments as Map<String, dynamic>?;
    fileName = arguments?['file'] as String?;
    print('fileName: $fileName');
    
    // 立即初始化控制器，不等待postFrameCallback
    _initWebController();
  }

  void _initWebController() async {
    try {
      print('开始初始化WebViewController');
      
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        // 启用更多Web功能以支持复杂页面
        ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              print('页面开始加载: $url');
              if (mounted) {
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
              }
            },
            onPageFinished: (String url) {
              print('页面加载完成: $url');
              // 给复杂页面更多时间渲染
              Future.delayed(Duration(milliseconds: 1000), () {
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
              });
            },
            onWebResourceError: (WebResourceError error) {
              print('WebView错误: ${error.description}');
              if (mounted) {
                setState(() {
                  hasError = true;
                  errorMessage = error.description;
                  isLoading = false;
                });
              }
            },
            onHttpError: (HttpResponseError error) {
              print('HTTP错误: ${error.response?.statusCode}');
              if (mounted) {
                setState(() {
                  hasError = true;
                  errorMessage = 'HTTP错误: ${error.response?.statusCode}';
                  isLoading = false;
                });
              }
            },
          ),
        );

      // 立即设置控制器并加载内容
      if (mounted) {
        setState(() {
          _controller = controller;
          isControllerReady = true;
        });
      }

      // 加载HTML文件
      if (fileName != null) {
        final assetPath = 'assets/html/$fileName';
        print('正在加载文件: $assetPath');
        controller.loadFlutterAsset(assetPath).then((_){
          setState(() {
            isLoading = false;
          });
        });
        print('文件加载调用完成');
      }

    } catch (e) {
      print('初始化WebViewController时出错: $e');
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = '初始化错误: $e';
          isLoading = false;
        });
      }
    }
  }

  void _retry() {
    if (mounted) {
      setState(() {
        hasError = false;
        errorMessage = '';
        isLoading = true;
        isControllerReady = false;
        _controller = null;
      });
    }
    _initWebController();
  }

  @override
  Widget build(BuildContext context) {
    print('FYWebView build called, controller: $isControllerReady, isLoading: $isLoading, hasError: $hasError');

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Container(
        color: Colors.white,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (hasError) {
      return _buildErrorWidget();
    }

    if (!isControllerReady || _controller == null) {
      return _buildLoadingWidget('正在初始化...');
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller!),
        if (isLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildLoadingWidget(String message) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (fileName != null) ...[
              SizedBox(height: 8),
              Text(
                '加载文件: $fileName',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              SizedBox(height: 16),
              Text(
                '加载失败',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _retry,
                icon: Icon(Icons.refresh),
                label: Text('重试'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 清理资源
    super.dispose();
  }
}
