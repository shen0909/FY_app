import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/https/api_service.dart';

import 'order_event_detial_state.dart';

class OrderEventDetialLogic extends GetxController {
  final OrderEventDetialState state = OrderEventDetialState();
  final ApiService _apiService = ApiService();

  @override
  void onReady() {
    super.onReady();
    // 获取路由参数
    final Map<String, dynamic>? args = Get.arguments;
    if (args != null && args.containsKey('eventTitle')) {
      loadEventDetails(args['eventTitle']);
    } else if (args != null && args.containsKey('eventUuid')) {
      loadEventDetailsByUuid(args['eventUuid']);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
  
  // 通过UUID加载事件详情
  Future<void> loadEventDetailsByUuid(String eventUuid) async {
    try {
      // 显示加载状态
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      
      // 并行获取事件详情和最新动态
      await Future.wait([
        loadEventDetail(eventUuid),
        loadEventLatestUpdates(eventUuid),
      ]);
      
      // 关闭加载对话框
      Get.back();
    } catch (e) {
      Get.back(); // 关闭加载对话框
      Get.snackbar(
        '错误', 
        '加载事件详情失败: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // 加载事件详情
  Future<void> loadEventDetail(String eventUuid) async {
    try {
      final result = await _apiService.getEventDetail(eventUuid: eventUuid);
      
      if (result != null && result['执行结果'] == true) {
        final eventData = result['返回数据'];
        
        state.eventTitle.value = eventData['event_name'] ?? '';
        state.eventDate.value = eventData['create_time'] ?? '';
        state.viewCount.value = eventData['view_count'] ?? 0;
        state.followCount.value = eventData['follow_count'] ?? 0;
        state.eventDescription.value = eventData['event_description'] ?? '';
        state.eventTags.assignAll(List<String>.from(eventData['tags'] ?? []));
        state.eventUuid.value = eventUuid;
      }
    } catch (e) {
      print('加载事件详情失败: $e');
    }
  }
  
  // 加载事件最新动态
  Future<void> loadEventLatestUpdates(String eventUuid) async {
    try {
      final result = await _apiService.getEventLatestUpdates(
        eventUuid: eventUuid,
        currentPage: 1,
        pageSize: 20,
      );
      
      if (result != null && result['执行结果'] == true) {
        final List<dynamic> updatesData = result['返回数据']['data'] ?? [];
        state.latestUpdates.clear();
        
        for (var update in updatesData) {
          state.latestUpdates.add({
            'uuid': update['uuid'] ?? '',
            'title': update['title'] ?? '',
            'content': update['content'] ?? '',
            'date': update['create_time'] ?? '',
            'type': update['type'] ?? '',
            'source': update['source'] ?? '',
          });
        }
      }
    } catch (e) {
      print('加载事件最新动态失败: $e');
    }
  }
  
  // 加载事件详情（兼容旧方法）
  void loadEventDetails(String eventTitle) {
    // 实际项目中应该从API获取数据
    // 这里使用模拟数据
    state.eventTitle.value = eventTitle;
    state.eventDate.value = '2025-04-26';
    state.viewCount.value = 152;
    state.followCount.value = 48;
    state.eventDescription.value = '该事件包含多个最新动态和分析报告，涉及全球贸易摩擦、关税政策变化以及对产业链的影响。';
    state.eventTags.assignAll(['贸易', '关税', '产业链']);
    
    // 添加最新动态
    state.latestUpdates.assignAll([
      {
        'title': '美国宣布对部分中国商品加征关税',
        'content': '美国贸易代表办公室宣布，将从下月起对价值约2000亿美元的中国进口商品加征25%的关税。',
        'date': '2025-04-26 09:00'
      },
      {
        'title': '欧盟考虑对数字服务征税',
        'content': '欧盟委员会正在讨论一项提案，计划对大型科技公司的数字服务收入征税，可能影响全球贸易格局。',
        'date': '2025-04-25 14:30'
      },
      {
        'title': '中日韩自贸区谈判取得新进展',
        'content': '最新一轮中日韩自贸区谈判结束，三方在货物贸易、服务贸易和投资等领域达成多项共识。',
        'date': '2025-04-24 11:00'
      },
      {
        'title': 'WTO发布全球贸易展望报告',
        'content': '世界贸易组织发布最新报告，预测未来两年全球商品贸易增速将放缓，呼吁各方维护多边贸易体制。',
        'date': '2025-04-23 16:00'
      },
      {
        'title': '贸易战下企业应对策略分析',
        'content': '行业专家发布研究报告，提出企业应通过多元化采购渠道、开拓新市场、加强科技创新等方式应对贸易摩擦带来的挑战。',
        'date': '2025-04-23 16:00'
      }
    ]);
  }
  
  // 查看详情
  void viewUpdateDetail(Map<String, dynamic> update) {
    Get.snackbar(
      '提示', 
      '正在查看 ${update['title']} 详情',
      backgroundColor: Colors.white,
      colorText: Color(0xFF1A1A1A),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // 查看更多动态
  void viewMoreUpdates() {
    Get.snackbar(
      '提示', 
      '查看更多${state.eventTitle.value}的动态',
      backgroundColor: Colors.white,
      colorText: Color(0xFF1A1A1A),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // 批量选择开关
  void batchCheck() {
    state.isBatchCheck.value = !state.isBatchCheck.value;
    
    // 退出批量选择模式时清空选中项
    if (!state.isBatchCheck.value) {
      state.selectedItems.clear();
    }
  }
  
  // 切换全选状态
  void toggleSelectAll() {
    if (state.selectedItems.length == state.latestUpdates.length) {
      // 如果全部选中，则取消全选
      state.selectedItems.clear();
    } else {
      // 否则全选
      state.selectedItems.assignAll(
        List.generate(state.latestUpdates.length, (index) => index)
      );
    }
  }
  
  // 删除选中的项目
  void deleteSelectedItems() {
    if (state.selectedItems.isEmpty) {
      Get.snackbar('提示', '请先选择要删除的项目');
      return;
    }
    
    Get.dialog(
      AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${state.selectedItems.length} 个项目吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _performDelete();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  // 执行删除操作
  void _performDelete() {
    // 这里可以调用API删除选中的项目
    // 暂时只是从本地列表中移除
    final sortedIndexes = state.selectedItems.toList()..sort((a, b) => b.compareTo(a));
    
    for (int index in sortedIndexes) {
      if (index >= 0 && index < state.latestUpdates.length) {
        state.latestUpdates.removeAt(index);
      }
    }
    
    state.selectedItems.clear();
    state.isBatchCheck.value = false;
    
    Get.snackbar('成功', '已删除选中的项目');
  }
  
  // 检查项目是否被选中
  bool isItemSelected(int index) {
    return state.selectedItems.contains(index);
  }
  
  // 切换项目选中状态
  void toggleItemSelection(int index) {
    if (state.selectedItems.contains(index)) {
      state.selectedItems.remove(index);
    } else {
      state.selectedItems.add(index);
    }
  }
  
  // 生成报告
  void generateReport() {
    if (state.selectedItems.isEmpty) {
      Get.snackbar('提示', '请先选择要生成报告的项目');
      return;
    }
    
    state.isGeneratingReport.value = true;
    state.reportGenerationStatus.value = ReportGenerationStatus.generating;
    
    // 模拟报告生成过程
    Future.delayed(const Duration(seconds: 3), () {
      state.isGeneratingReport.value = false;
      state.reportGenerationStatus.value = ReportGenerationStatus.success;
      
      // 设置报告信息
      state.reportInfo.value = {
        'title': '事件分析报告',
        'date': DateTime.now().toString(),
        'items': state.selectedItems.length,
        'eventName': state.eventTitle.value,
      };
      
      Get.snackbar('成功', '报告生成完成');
    });
  }
  
  // 取消选择模式
  void cancelSelection() {
    state.selectedItems.clear();
    state.isBatchCheck.value = false;
  }
  
  // 关闭报告对话框
  void closeReportDialog() {
    state.reportGenerationStatus.value = ReportGenerationStatus.none;
    state.reportInfo.clear();
  }
  
  // 预览报告
  void previewReport() {
    if (state.reportInfo.isEmpty) {
      Get.snackbar('提示', '没有可预览的报告');
      return;
    }
    
    Get.dialog(
      AlertDialog(
        title: const Text('报告预览'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('标题: ${state.reportInfo['title']}'),
            Text('日期: ${state.reportInfo['date']}'),
            Text('项目数: ${state.reportInfo['items']}'),
            Text('事件名称: ${state.reportInfo['eventName']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  // 下载报告
  void downloadReport() {
    if (state.reportInfo.isEmpty) {
      Get.snackbar('提示', '没有可下载的报告');
      return;
    }
    
    // 模拟下载过程
    Get.snackbar('下载中', '正在下载报告...');
    
    Future.delayed(const Duration(seconds: 2), () {
      Get.snackbar('成功', '报告下载完成');
    });
  }
  
  // 刷新数据
  Future<void> refreshData() async {
    if (state.eventUuid.value.isNotEmpty) {
      await loadEventDetailsByUuid(state.eventUuid.value);
    }
  }
  
  // 关注/取消关注事件
  Future<void> toggleEventFollow() async {
    try {
      // 这里可以调用API来关注/取消关注事件
      // 暂时使用本地状态切换
      if (state.isFollowed.value) {
        state.isFollowed.value = false;
        state.followCount.value--;
        Get.snackbar('成功', '已取消关注该事件');
      } else {
        state.isFollowed.value = true;
        state.followCount.value++;
        Get.snackbar('成功', '已关注该事件');
      }
    } catch (e) {
      Get.snackbar('错误', '操作失败: $e');
    }
  }
}
