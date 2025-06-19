import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

/// Markdown消息渲染组件
class MarkdownMessageWidget extends StatelessWidget {
  final String content;
  final bool isUser;
  final bool isStreaming;

  const MarkdownMessageWidget({
    Key? key,
    required this.content,
    required this.isUser,
    this.isStreaming = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      // 用户消息使用普通文本显示
      return _buildUserMessage();
    } else {
      // AI消息使用Markdown渲染
      return _buildAIMessage();
    }
  }

  Widget _buildUserMessage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF3361FE),
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.white,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildAIMessage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarkdownBody(
            data: content,
            fitContent: false,
            styleSheet: MarkdownStyleSheet(
                blockSpacing: 12.w,
                // 表格
                tableBorder: TableBorder.all(color: Colors.black12),
                // 水平线
                horizontalRuleDecoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.black12, width: 1.w)),
                ),
                // 代码块
                codeblockDecoration: BoxDecoration(
                  color: Color(0xfff8f8f8),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                // 引用
                blockquotePadding: EdgeInsets.only(
                    left: 16.w, top: 8.w, bottom: 8.w),
                blockquoteDecoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(color: Colors.black12, width: 4.w)),
                )
            ),
            builders: {
              // 自定义代码/代码块构建
              // 'code': CustomCodeBuilder(),
            },
            // 自定义图片构建
            // sizedImageBuilder: (config) => ImageBuilderWidget(config: config),
            // 点击链接
            onTapLink: (text, href, title) async {
              if (href != null) {
                if (await canLaunchUrl(Uri.parse(href))) {
                  await launchUrl(Uri.parse(href));
                } else {
                  debugPrint('无法访问 $href');
                }
              }
            },
          ),
          if (isStreaming)
            Padding(
              padding: EdgeInsets.only(top: 8.w),
              child: Row(
                children: [
                  SizedBox(
                    width: 12.w,
                    height: 12.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF3361FE),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '正在回复...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      // 段落样式
      p: TextStyle(
        fontSize: 14.sp,
        color: const Color(0xFF1A1A1A),
        height: 1.5,
      ),
      // 标题样式
      h1: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1A1A),
        height: 1.3,
      ),
      h2: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1A1A),
        height: 1.3,
      ),
      h3: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1A1A),
        height: 1.3,
      ),
      // 强调样式
      strong: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1A1A),
      ),
      em: TextStyle(
        fontSize: 14.sp,
        fontStyle: FontStyle.italic,
        color: const Color(0xFF1A1A1A),
      ),
      // 代码样式
      code: TextStyle(
        fontSize: 13.sp,
        color: const Color(0xFF3361FE),
        backgroundColor: const Color(0xFFE8F0FF),
        fontFamily: 'monospace',
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      codeblockPadding: EdgeInsets.all(12.w),
      // 列表样式
      listBullet: TextStyle(
        fontSize: 14.sp,
        color: const Color(0xFF1A1A1A),
      ),
      // 链接样式
      a: TextStyle(
        fontSize: 14.sp,
        color: const Color(0xFF3361FE),
        decoration: TextDecoration.underline,
      ),
      // 引用样式
      blockquote: TextStyle(
        fontSize: 14.sp,
        color: const Color(0xFF666666),
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: const Color(0xFF3361FE),
            width: 3.w,
          ),
        ),
      ),
      blockquotePadding: EdgeInsets.only(left: 12.w),
      // 表格样式
      tableHead: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1A1A),
      ),
      tableBody: TextStyle(
        fontSize: 14.sp,
        color: const Color(0xFF1A1A1A),
      ),
      tableBorder: TableBorder.all(
        color: const Color(0xFFE0E0E0),
        width: 1,
      ),
      // 水平分割线
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE0E0E0),
            width: 1.w,
          ),
        ),
      ),
    );
  }
} 