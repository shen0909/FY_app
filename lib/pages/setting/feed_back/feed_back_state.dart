import 'package:get/get.dart';

class FeedBackState {
  // 反馈类型选项
  final List<String> feedbackTypes = [
    '关键词反馈',
    '网站来源反馈',
    '选项一',
    '功能建议',
    '其它反馈',
    '功能异常',
  ];
  
  // 选中的反馈类型
  final RxString selectedType = ''.obs;
  
  // 反馈详情
  final RxString feedbackDetail = ''.obs;
  
  FeedBackState() {
    ///Initialize variables
  }
}
