import 'package:get/get.dart';
import 'package:safe_app/utils/toast_util.dart';

import '../../../cache/business_cache_service.dart';
import '../../../utils/dialog_utils.dart';
import 'use_tutorial_state.dart';

class UseTutorialLogic extends GetxController {
  final UseTutorialState state = UseTutorialState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    getTutorialContent();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
  
  // 切换标签页
  void switchTab(int index) {
    state.selectedTabIndex.value = index;
  }
  
  // 切换视频播放状态
  void togglePlayPause() {
    state.isPlaying.value = !state.isPlaying.value;
  }
  
  // 更新视频进度
  void updateVideoProgress(double progress) {
    state.currentProgress.value = progress;
  }
  
  // 发送教程反馈
  void sendFeedback(bool isHelpful) {
    // 实际应用中这里应该发送反馈到后端
    ToastUtil.showShort('感谢您的反馈，我们将不断完善教程内容', title: '反馈成功');
  }
  
  // 播放视频教程
  void playVideoTutorial(int index) {
    // 实际应用中这里应该播放视频
    final tutorial = state.videoTutorials[index];
    
    // 检查权限
    if (tutorial['requiresPermission'] == true) {
      // 检查当前用户是否有权限，这里简化处理
      bool hasPermission = false; // 从用户状态或服务获取
      
      if (!hasPermission) {
        ToastUtil.showShort('该视频仅对管理员和审核员开放', title: '权限不足');
        return;
      }
    }
    
    // 开始播放视频
    state.isPlaying.value = true;
    
    // 更新当前播放的视频
    // TODO: 实现实际的视频播放逻辑
  }
  
  // 联系技术支持
  void contactSupport() {
    ToastUtil.showShort('已经复制技术支持联系方式到剪贴板', title: '联系技术支持');
  }

  /// 处理收起逻辑
  dealExpand(int index) {
    if(index == 0){
      state.isExpandAi.value = !state.isExpandAi.value;
    }
    if(index == 1){
      state.isExpandPermission.value = !state.isExpandPermission.value;
    }
    if(index == 2){
      state.isExpandData.value = !state.isExpandData.value;
    }
  }

  Future<void> getTutorialContent() async {
    DialogUtils.showLoading();
    final result = await BusinessCacheService.instance.getTutorialContentWithCache();
    DialogUtils.hideLoading();
    if(result != null) {
      state.tutorialContent.value = result['content'];
    }
  }
}
