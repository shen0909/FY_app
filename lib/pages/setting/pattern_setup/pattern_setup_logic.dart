import 'package:get/get.dart';
import 'package:safe_app/utils/pattern_lock_util.dart';

import 'pattern_setup_state.dart';

class PatternSetupLogic extends GetxController {
  final PatternSetupState state = PatternSetupState();

  @override
  void onReady() {
    super.onReady();
    // 初始化操作
  }

  @override
  void onClose() {
    super.onClose();
  }
  
  // 设置第一次绘制的图案
  void setPattern(List<int> pattern) {
    if (pattern.length < 4) {
      state.errorMessage.value = '图案太简单，请至少连接4个点';
      Future.delayed(const Duration(seconds: 1), () {
        state.errorMessage.value = '';
      });
      return;
    }
    
    state.firstPattern.clear();
    state.firstPattern.addAll(pattern);
    state.currentStep.value = PatternStep.confirm;
    state.errorMessage.value = '';
  }
  
  // 确认图案
  void confirmPattern(List<int> pattern) {
    if (pattern.length != state.firstPattern.length) {
      _showPatternError('图案不匹配，请重试');
      return;
    }
    
    for (int i = 0; i < pattern.length; i++) {
      if (pattern[i] != state.firstPattern[i]) {
        _showPatternError('图案不匹配，请重试');
        return;
      }
    }
    
    // 图案匹配，保存图案
    _savePattern();
  }
  
  // 保存图案
  Future<void> _savePattern() async {
    final result = await PatternLockUtil.savePattern(state.firstPattern);
    if (result) {
      await PatternLockUtil.enablePatternLock(true);
      state.currentStep.value = PatternStep.success;
    } else {
      _showPatternError('图案保存失败，请重试');
    }
  }
  
  // 显示错误信息
  void _showPatternError(String message) {
    state.isError.value = true;
    state.errorMessage.value = message;
    
    Future.delayed(const Duration(seconds: 1), () {
      state.isError.value = false;
      state.errorMessage.value = '';
    });
  }
  
  // 重置图案设置
  void resetPattern() {
    state.firstPattern.clear();
    state.errorMessage.value = '';
    state.isError.value = false;
    state.currentStep.value = PatternStep.create;
  }
} 