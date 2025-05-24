import 'package:get/get.dart';

enum PatternStep {
  create,
  confirm,
  success,
}

class PatternSetupState {
  // 当前步骤
  final Rx<PatternStep> currentStep = PatternStep.create.obs;
  
  // 第一次绘制的图案
  final RxList<int> firstPattern = <int>[].obs;
  
  // 错误消息
  final RxString errorMessage = ''.obs;
  
  // 是否显示错误
  final RxBool isError = false.obs;
  
  PatternSetupState() {
    // 初始化操作
  }
} 