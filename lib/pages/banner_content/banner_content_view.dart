import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import '../../widgets/custom_app_bar.dart';
import 'banner_content_logic.dart';

class BannerContentPage extends StatefulWidget {
  const BannerContentPage({Key? key}) : super(key: key);

  @override
  State<BannerContentPage> createState() => _BannerContentPageState();
}

class _BannerContentPageState extends State<BannerContentPage> {
  final BannerContentLogic logic = Get.put(BannerContentLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FYColors.whiteColor,
      appBar: FYAppBar(title: logic.title),
      body: Markdown(
        data: logic.content,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            fontSize: 16.sp,
            color: FYColors.color_1A1A1A,
            height: 1.6,
          ),
          h1: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: FYColors.color_1A1A1A,
          ),
          h2: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: FYColors.color_1A1A1A,
          ),
          h3: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: FYColors.color_1A1A1A,
          ),
          blockquote: TextStyle(
            fontSize: 16.sp,
            color: FYColors.color_666666,
            fontStyle: FontStyle.italic,
          ),
          code: TextStyle(
            fontSize: 14.sp,
            backgroundColor: FYColors.color_F5F5F5,
            fontFamily: 'monospace',
          ),
          blockSpacing: 16.h,
          listIndent: 24.w,
        ),
      ),
    );
  }
} 