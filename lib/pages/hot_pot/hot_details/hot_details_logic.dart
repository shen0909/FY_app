import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/models/news_detail_data.dart';
import 'package:safe_app/pages/hot_pot/hot_details/hot_details_state.dart';
import 'package:safe_app/models/newslist_data.dart';
import 'package:safe_app/utils/dialog_utils.dart';

class HotDetailsLogic extends GetxController {
  final HotDetailsState state = HotDetailsState();

  @override
  void onInit() {
    super.onInit();
    // 获取传入的参数
    if (Get.arguments != null && Get.arguments['newsId'] != null) {
      state.newsId.value = Get.arguments['newsId'];
      // 获取新闻详情
      fetchNewsDetail();
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // 获取新闻详情
  Future<void> fetchNewsDetail() async {
    state.isLoading.value = true;
    state.errorMessage.value = '';
    
    try {
      print('正在获取新闻ID: ${state.newsId.value} 的详情');
      final result = await ApiService().getNewsDetail(newsId: state.newsId.value);
      
      // 检查API响应状态
      if (result != null && result['code'] == 10010 && result['data'] != null) {
        // 打印原始数据结构
        print('API返回详情数据结构: ${result['data'].runtimeType}');
        print('API返回effect字段类型: ${result['data']['effect']?.runtimeType}');
        print('API返回relevant_news字段类型: ${result['data']['relevant_news']?.runtimeType}');
        
        // 将返回的JSON数据保存
        state.newsDetail.value = result['data'];
        
        try {
          // 尝试转换为类型化的NewsDetail对象
          print('开始转换NewsDetail对象');
          state.newsDetailData.value = NewsDetail.fromJson(result['data']);
          print('NewsDetail对象转换成功');
        } catch (conversionError) {
          // 捕获数据转换错误
          print('数据转换错误: $conversionError');
          state.errorMessage.value = '数据格式错误: $conversionError';
        }
      } else {
        // API响应错误
        print('API响应错误: ${result?['msg'] ?? '未知错误'}');
        state.errorMessage.value = result?['msg'] ?? '获取新闻详情失败';
      }
    } catch (e) {
      // 网络或其他错误
      print('请求异常: $e');
      state.errorMessage.value = e.toString();
    } finally {
      state.isLoading.value = false;
    }
  }

  // 切换标签页
  void changeTab(int index) {
    state.activeTabIndex.value = index;
    ;
  }

  // 下载相关文件
  void downloadFile() {
    // 显示建设中提示
    DialogUtils.showUnderConstructionDialog();
  }

  // 复制内容
  void copyContent(String content) {
    Clipboard.setData(ClipboardData(text: content));
    Get.snackbar(
      '复制成功',
      '内容已复制到剪贴板',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // 分享内容
  void shareContent() {
    // 实际应用中这里会调用分享API
    Get.snackbar(
      '分享提示',
      '分享功能已触发',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // 添加到收藏
  void addToFavorites() {
    // 实际应用中这里会实现收藏功能
    Get.snackbar(
      '收藏提示',
      '已添加到收藏',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  changeTranslate(int index) {
    state.activeTranslateIndex.value = index;
  }
}

