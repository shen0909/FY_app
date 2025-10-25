import 'package:get/get.dart';

class BannerContentLogic extends GetxController {
  late String title;
  late String content;

  @override
  void onInit() {
    super.onInit();
    // 从路由参数中获取标题和内容
    final arguments = Get.arguments as Map<String, dynamic>?;
    title = arguments?['title'] ?? '内容详情';
    content = arguments?['content'] ?? '暂无内容';
  }
} 