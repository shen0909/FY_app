import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../routers/routers.dart';

/// Markdown消息渲染组件
class MarkdownMessageWidget extends StatefulWidget {
  final String content;
  final String title;
  final bool isUser;
  final bool isStreaming;
  final bool isShowName; //是否展示智能体名称
  final bool isAI;
  final List<Map<String, dynamic>>? searchResults; // 参考来源
  final List<Map<String, dynamic>>? knowledgeBase; // 本地知识库

  const MarkdownMessageWidget({
    Key? key,
    required this.content,
    this.title = '',
    this.isUser = true,
    this.isStreaming = false,
    this.isAI = true,
    required this.isShowName,
    this.searchResults,
    this.knowledgeBase,
  }) : super(key: key);

  @override
  State<MarkdownMessageWidget> createState() => _MarkdownMessageWidgetState();
}

class _MarkdownMessageWidgetState extends State<MarkdownMessageWidget> {
  bool _isSearchResultsExpanded = false; // 参考来源展开状态

  @override
  Widget build(BuildContext context) {
    if (widget.isUser) {
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
        widget.content,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.white,
          height: 1.4,
          fontFamily: 'AlibabaPuHuiTi',
        ),
      ),
    );
  }

  Widget _buildAIMessage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      decoration: BoxDecoration(
        color: widget.isAI ?  Color(0xFFF5F5F5) : Colors.white,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(widget.isShowName)
            Padding(
              padding: EdgeInsets.only(bottom: 6.w),
              child: Text('${widget.title}: ',style: TextStyle(fontSize: 10.sp,color: FYColors.color_3361FE,fontWeight: FontWeight.w400)),
            ),
          MarkdownBody(
            data: widget.content,
            fitContent: true,
            styleSheet: _buildMarkdownStyleSheet(),
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
          if (widget.isStreaming)
            Padding(
              padding: EdgeInsets.only(top: 8.w),
              child: Row(
                children: [
                  SizedBox(
                    width: 12.w,
                    height: 12.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF3361FE),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '正在回复...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF999999),
                      fontFamily: 'AlibabaPuHuiTi',
                    ),
                  ),
                ],
              ),
            ),
          // 参考来源和知识库
          if (widget.searchResults != null && widget.searchResults!.isNotEmpty ||
              widget.knowledgeBase != null && widget.knowledgeBase!.isNotEmpty)
            _buildReferenceSources(),
        ],
      ),
    );
  }

  // 构建参考来源和知识库区域
  Widget _buildReferenceSources() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.w),
        Divider(height: 1.w, thickness: 1.w, color: Color(0xFFE6E6E6)),
        SizedBox(height: 12.w),
        // 参考来源
        if (widget.searchResults != null && widget.searchResults!.isNotEmpty) ...[
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearchResultsExpanded = !_isSearchResultsExpanded;
              });
            },
            child: Row(
              children: [
                // Image.asset(
                //   'assets/images/reference_icon.png',
                //   width: 16.w,
                //   height: 16.w,
                //   errorBuilder: (context, error, stackTrace) {
                //     return Icon(Icons.public, size: 16.w, color: Color(0xFF3361FE));
                //   },
                // ),
                // SizedBox(width: 4.w),
                Text(
                  '参考来源',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4.w),
                // Spacer(),
                Icon(
                  _isSearchResultsExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                  size: 20.w,
                ),
              ],
            ),
          ),
          if (_isSearchResultsExpanded) ...[
            SizedBox(height: 8.w),
            Text(
              '联网检索:',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.w),
            ...widget.searchResults!.map((result) => _buildSearchResultItem(result)),
            SizedBox(height: 12.w),
            // 本地知识库
            if (widget.knowledgeBase != null && widget.knowledgeBase!.isNotEmpty) ...[
              Text(
                '本地知识库+:',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.w),
              ...widget.knowledgeBase!.map((kb) => _buildKnowledgeBaseItem(kb)),
            ],
          ],
        ],
      ],
    );
  }

  // 构建单个参考来源项
  Widget _buildSearchResultItem(Map<String, dynamic> result) {
    final String title = result['title'] ?? '';
    final int index = result['index'] ?? '';
    final String newsUuid = result['news_uuid'] ?? '';
    final String source = result['source'] ?? '';

    return Container(
      padding: EdgeInsets.only(bottom: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '[$index]',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // if (source.isNotEmpty) ...[
          //   SizedBox(height: 4.w),
          //   Text(
          //     '-:$source',
          //     style: TextStyle(
          //       fontSize: 10.sp,
          //       color: Color(0xFFA6A6A6),
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }

  // 构建单个知识库项
  Widget _buildKnowledgeBaseItem(Map<String, dynamic> kb) {
    final String title = kb['title'] ?? '';
    final int index = kb['index'] ?? '';
    final String newsUuid = kb['news_uuid'] ?? '';
    final double relevanceScore = (kb['relevance_score'] ?? 0.0).toDouble();

    return GestureDetector(
      onTap: () {
        if (newsUuid.isNotEmpty) {
          // 跳转到新闻详情页
          Get.toNamed(Routers.hotDetails, arguments: {'news_uuid': newsUuid});
        }
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 8.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '<$index>',
              style: TextStyle(
                fontSize: 12.sp,
                color: Color(0xFF3361FE),
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Color(0xFF3361FE),
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      blockSpacing: 12.w,
      // 段落样式
      p: TextStyle(
        fontSize: 14.sp,
        color: const Color(0xFF1A1A1A),
        height: 1.5,
        fontFamily: 'AlibabaPuHuiTi',
      ),
      // 标题样式
      h1: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1A1A),
        height: 1.3,
        fontFamily: 'AlibabaPuHuiTi',
      ),
      h2: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1A1A),
        height: 1.3,
        fontFamily: 'AlibabaPuHuiTi',
      ),
      h3: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1A1A),
        height: 1.3,
        fontFamily: 'AlibabaPuHuiTi',
      ),
      // 强调样式
      strong: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1A1A),
        fontFamily: 'AlibabaPuHuiTi',
      ),
      em: TextStyle(
        fontSize: 14.sp,
        fontStyle: FontStyle.italic,
        color: const Color(0xFF1A1A1A),
        fontFamily: 'AlibabaPuHuiTi',
      ),
      // 代码样式
      code: TextStyle(
        fontSize: 13.sp,
        color: const Color(0xFF3361FE),
        backgroundColor: const Color(0xFFE8F0FF),
        fontFamily: 'monospace',
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10.r),
      ),
      codeblockPadding: EdgeInsets.all(12.w),
      // 列表样式
      listBullet: TextStyle(
        fontSize: 14.sp,
        color: const Color(0xFF1A1A1A),
        fontFamily: 'AlibabaPuHuiTi',
      ),
      // 链接样式
      a: TextStyle(
        fontSize: 14.sp,
        color: const Color(0xFF3361FE),
        decoration: TextDecoration.underline,
        fontFamily: 'AlibabaPuHuiTi',
      ),
      // 引用样式
      blockquote: TextStyle(
        fontSize: 14.sp,
        color: const Color(0xFF666666),
        fontStyle: FontStyle.italic,
        fontFamily: 'AlibabaPuHuiTi',
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: const Color(0xFF3361FE),
            width: 3.w,
          ),
        ),
      ),
      blockquotePadding: EdgeInsets.only(left: 12.w, top: 8.w, bottom: 8.w),
      // 表格样式
      tableHead: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1A1A),
        fontFamily: 'AlibabaPuHuiTi',
      ),
      tableBody: TextStyle(
        fontSize: 14.sp,
        color: const Color(0xFF1A1A1A),
        fontFamily: 'AlibabaPuHuiTi',
      ),
      tableBorder: TableBorder.all(
        color: const Color(0xFFE0E0E0),
        width: 1.w,
      ),
      // 水平分割线
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE0E0E0),
            width: 1.w,
          ),
        ),
      ),
    );
  }
} 