import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'document_preview_logic.dart';
import 'document_preview_state.dart';
import '../../styles/colors.dart';

class DocumentPreviewView extends StatelessWidget {
  const DocumentPreviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(DocumentPreviewLogic());
    final state = logic.state;

    return Obx(() => Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(logic, state),
      body: _buildBody(logic, state),
      bottomNavigationBar: _buildBottomBar(logic, state),
    ));
  }

  // 构建应用栏
  PreferredSizeWidget _buildAppBar(DocumentPreviewLogic logic, DocumentPreviewState state) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => logic.goBack(),
      ),
      title: Text(
        state.documentTitle.value,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        // 预览模式切换按钮
        if (state.supportsInAppPreview.value)
          IconButton(
            icon: Icon(
              state.previewMode.value == 'in_app' 
                ? Icons.open_in_browser 
                : Icons.visibility,
              color: Colors.black87,
            ),
            onPressed: () => logic.togglePreviewMode(),
            tooltip: state.previewMode.value == 'in_app' 
              ? '切换到外部预览' 
              : '切换到应用内预览',
          ),
        // 刷新按钮
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.black87),
          onPressed: () => logic.refreshPreview(),
          tooltip: '刷新预览',
        ),
        // 更多操作按钮
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.black87),
          onSelected: (value) {
            switch (value) {
              case 'download':
                logic.downloadDocument();
                break;
              case 'share':
                logic.shareDocument();
                break;
              case 'fullscreen':
                logic.toggleFullScreen();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download, size: 20.w),
                  SizedBox(width: 8.w),
                  Text('下载文档'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20.w),
                  SizedBox(width: 8.w),
                  Text('分享文档'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'fullscreen',
              child: Row(
                children: [
                  Icon(
                    state.isFullScreen.value ? Icons.fullscreen_exit : Icons.fullscreen,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(state.isFullScreen.value ? '退出全屏' : '全屏预览'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 构建主体内容
  Widget _buildBody(DocumentPreviewLogic logic, DocumentPreviewState state) {
    // if (state.isError.value) {
    //   return _buildErrorView(logic, state);
    // }

    // if (state.isLoading.value) {
    //   return _buildLoadingView(state);
    // }
    //
    // if (state.previewMode.value == 'external') {
    //   return _buildExternalPreviewView(state);
    // }

    return _buildInAppPreviewView(logic, state);
  }

  // 构建错误视图
  // Widget _buildErrorView(DocumentPreviewLogic logic, DocumentPreviewState state) {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(
  //           Icons.error_outline,
  //           size: 80.w,
  //           color: Colors.red[300],
  //         ),
  //         SizedBox(height: 20.h),
  //         Text(
  //           '预览失败',
  //           style: TextStyle(
  //             fontSize: 24.sp,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.red[700],
  //           ),
  //         ),
  //         SizedBox(height: 12.h),
  //         Text(
  //           state.errorMessage.value,
  //           style: TextStyle(
  //             fontSize: 16.sp,
  //             color: Colors.grey[600],
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //         SizedBox(height: 30.h),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             ElevatedButton.icon(
  //               onPressed: () => logic._loadDocument(),
  //               icon: Icon(Icons.refresh),
  //               label: Text('重试'),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: FYColors.loginBtn[0],
  //                 foregroundColor: Colors.white,
  //                 padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
  //               ),
  //             ),
  //             SizedBox(width: 16.w),
  //             OutlinedButton.icon(
  //               onPressed: () => logic.togglePreviewMode(),
  //               icon: Icon(Icons.open_in_browser),
  //               label: Text('外部预览'),
  //               style: OutlinedButton.styleFrom(
  //                 padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // 构建加载视图
  Widget _buildLoadingView(DocumentPreviewState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value: state.downloadProgress.value > 0 ? state.downloadProgress.value : null,
            strokeWidth: 4.w,
            valueColor: AlwaysStoppedAnimation<Color>(FYColors.loginBtn[0]),
          ),
          SizedBox(height: 20.h),
          Text(
            '正在加载文档...',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[600],
            ),
          ),
          if (state.downloadProgress.value > 0) ...[
            SizedBox(height: 12.h),
            Text(
              '${(state.downloadProgress.value * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 构建外部预览视图
  // Widget _buildExternalPreviewView(DocumentPreviewState state) {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(
  //           Icons.open_in_browser,
  //           size: 80.w,
  //           color: Colors.blue[300],
  //         ),
  //         SizedBox(height: 20.h),
  //         Text(
  //           '外部预览模式',
  //           style: TextStyle(
  //             fontSize: 24.sp,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.blue[700],
  //           ),
  //         ),
  //         SizedBox(height: 12.h),
  //         Text(
  //           '文档将在外部应用中打开',
  //           style: TextStyle(
  //             fontSize: 16.sp,
  //             color: Colors.grey[600],
  //           ),
  //         ),
  //         SizedBox(height: 30.h),
  //         ElevatedButton.icon(
  //           onPressed: () => logic._loadExternal(),
  //           icon: Icon(Icons.open_in_new),
  //           label: Text('打开文档'),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: FYColors.loginBtn[0],
  //             foregroundColor: Colors.white,
  //             padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // 构建应用内预览视图
  Widget _buildInAppPreviewView(DocumentPreviewLogic logic, DocumentPreviewState state) {
    return Column(
      children: [
        // 文档信息栏
        if (!state.isFullScreen.value) _buildDocumentInfoBar(state),
        
        // 预览区域
        Expanded(
          child: Container(
            color: Colors.grey[100],
            child: Stack(
              children: [
                // WebView预览
                WebViewWidget(
                  controller: logic.webViewController!,
                ),
                
                // 加载指示器
                if (state.isLoading.value)
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 3.w,
                            valueColor: AlwaysStoppedAnimation<Color>(FYColors.loginBtn[0]),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            '加载中...',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 构建文档信息栏
  Widget _buildDocumentInfoBar(DocumentPreviewState state) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 文档类型图标
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _getDocumentTypeColor(state.documentType.value),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              _getDocumentTypeIcon(state.documentType.value),
              color: Colors.white,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          
          // 文档信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.documentTitle.value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (state.fileSize.value.isNotEmpty || state.lastModified.value.isNotEmpty)
                  Text(
                    '${state.fileSize.value} • ${state.lastModified.value}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          
          // 预览模式标识
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '应用内预览',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建底部工具栏
  Widget _buildBottomBar(DocumentPreviewLogic logic, DocumentPreviewState state) {
    if (state.isFullScreen.value || state.previewMode.value == 'external') {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 导航按钮
          IconButton(
            onPressed: () => logic.goBack(),
            icon: Icon(Icons.arrow_back, size: 24.w),
            tooltip: '返回',
          ),
          IconButton(
            onPressed: () => logic.goForward(),
            icon: Icon(Icons.arrow_forward, size: 24.w),
            tooltip: '前进',
          ),
          
          SizedBox(width: 16.w),
          
          // // 缩放控制
          // IconButton(
          //   onPressed: () => logic.zoomOut(),
          //   icon: Icon(Icons.zoom_out, size: 24.w),
          //   tooltip: '缩小',
          // ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '${(state.zoomLevel.value * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          // IconButton(
          //   onPressed: () => logic.zoomIn(),
          //   icon: Icon(Icons.zoom_in, size: 24.w),
          //   tooltip: '放大',
          // ),
          // IconButton(
          //   onPressed: () => logic.resetZoom(),
          //   icon: Icon(Icons.crop_square, size: 24.w),
          //   tooltip: '重置缩放',
          // ),
          
          Spacer(),
          
          // 全屏按钮
          IconButton(
            onPressed: () => logic.toggleFullScreen(),
            icon: Icon(
              state.isFullScreen.value ? Icons.fullscreen_exit : Icons.fullscreen,
              size: 24.w,
            ),
            tooltip: state.isFullScreen.value ? '退出全屏' : '全屏预览',
          ),
        ],
      ),
    );
  }

  // 获取文档类型图标
  IconData _getDocumentTypeIcon(String documentType) {
    final type = documentType.toLowerCase();
    if (type.contains('.pdf')) return Icons.picture_as_pdf;
    if (type.contains('.doc') || type.contains('.docx')) return Icons.description;
    if (type.contains('.xls') || type.contains('.xlsx')) return Icons.table_chart;
    if (type.contains('.ppt') || type.contains('.pptx')) return Icons.slideshow;
    return Icons.insert_drive_file;
  }

  // 获取文档类型颜色
  Color _getDocumentTypeColor(String documentType) {
    final type = documentType.toLowerCase();
    if (type.contains('.pdf')) return Colors.red[600]!;
    if (type.contains('.doc') || type.contains('.docx')) return Colors.blue[600]!;
    if (type.contains('.xls') || type.contains('.xlsx')) return Colors.green[600]!;
    if (type.contains('.ppt') || type.contains('.pptx')) return Colors.orange[600]!;
    return Colors.grey[600]!;
  }
} 