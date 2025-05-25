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
  
  // 提示消息
  final RxString promptMessage = ''.obs;
  
  // 是否显示错误
  final RxBool isError = false.obs;
  
  // 刷新触发器，用于强制重建控件
  final RxInt refreshTrigger = 0.obs;
  
  PatternSetupState() {
    // 初始化操作
  }
} 