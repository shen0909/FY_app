import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../styles/colors.dart';
import '../../routers/routers.dart';

class DocumentPreviewExample extends StatelessWidget {
  const DocumentPreviewExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文档预览示例'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '支持预览的文档格式',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
            
            // 支持的文档类型列表
            _buildDocumentTypeCard(
              'PDF文档',
              '支持应用内预览，可缩放、翻页',
              Icons.picture_as_pdf,
              Colors.red[600]!,
              'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
            ),
            
            SizedBox(height: 16.h),
            
            _buildDocumentTypeCard(
              'Word文档',
              '使用Office Online在线预览',
              Icons.description,
              Colors.blue[600]!,
              'https://file-examples.com/storage/fe8c7eef0c6364f6c9504cc/2017/10/file-sample_100kB.doc',
            ),
            
            SizedBox(height: 16.h),
            
            _buildDocumentTypeCard(
              'Excel表格',
              '使用Office Online在线预览',
              Icons.table_chart,
              Colors.green[600]!,
              'https://file-examples.com/storage/fe8c7eef0c6364f6c9504cc/2017/10/file-sample_100kB.xls',
            ),
            
            SizedBox(height: 16.h),
            
            _buildDocumentTypeCard(
              'PowerPoint演示',
              '使用Office Online在线预览',
              Icons.slideshow,
              Colors.orange[600]!,
              'https://file-examples.com/storage/fe8c7eef0c6364f6c9504cc/2017/10/file-sample_100kB.ppt',
            ),
            
            Spacer(),
            
            // 功能说明
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600], size: 24.w),
                      SizedBox(width: 8.w),
                      Text(
                        '功能特性',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildFeatureItem('✓ 应用内预览，无需跳转外部应用'),
                  _buildFeatureItem('✓ 支持多种文档格式'),
                  _buildFeatureItem('✓ 缩放、翻页、全屏等操作'),
                  _buildFeatureItem('✓ 下载和分享功能'),
                  _buildFeatureItem('✓ 错误处理和重试机制'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTypeCard(
    String title,
    String description,
    IconData icon,
    Color color,
    String sampleUrl,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => _previewDocument(title, sampleUrl),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  void _previewDocument(String title, String url) {
    Get.toNamed(Routers.documentPreview, arguments: {
      'documentUrl': url,
      'documentTitle': title,
      'documentType': title,
    });
  }
} 