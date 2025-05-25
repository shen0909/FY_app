import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'order_event_detial_state.dart';

class OrderEventDetialLogic extends GetxController {
  final OrderEventDetialState state = OrderEventDetialState();

  @override
  void onReady() {
    super.onReady();
    // 获取路由参数
    final Map<String, dynamic>? args = Get.arguments;
    if (args != null && args.containsKey('eventTitle')) {
      loadEventDetails(args['eventTitle']);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
  
  // 加载事件详情
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
  
  // 切换项目选中状态
  void toggleItemSelection(int index) {
    if (!state.isBatchCheck.value) return;
    
    if (state.selectedItems.contains(index)) {
      state.selectedItems.remove(index);
    } else {
      state.selectedItems.add(index);
    }
    
    // 刷新选中状态
    state.selectedItems.refresh();
  }
  
  // 检查项目是否被选中
  bool isItemSelected(int index) {
    return state.selectedItems.contains(index);
  }
  
  // 生成报告
  void generateReport() {
    if (state.selectedItems.isEmpty) {
      Get.snackbar(
        '提示', 
        '请先选择至少一条动态',
        backgroundColor: Colors.white,
        colorText: Color(0xFF1A1A1A),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    // 获取选中的动态项
    final List<Map<String, dynamic>> selectedUpdates = state.selectedItems
        .map((index) => state.latestUpdates[index])
        .toList();
    
    // 显示生成报告中的弹窗
    state.isGeneratingReport.value = true;
    state.reportGenerationStatus.value = ReportGenerationStatus.generating;
    
    // 模拟生成报告的过程，实际项目中应该调用API
    Future.delayed(Duration(seconds: 2), () {
      // 生成报告完成后更新状态
      state.reportGenerationStatus.value = ReportGenerationStatus.success;
      
      // 设置报告信息
      state.reportInfo.value = {
        'title': state.eventTitle.value,
        'date': state.eventDate.value,
        'fileType': 'word文档',
        'size': '4.2 MB',
        'description': '包含${state.selectedItems.length}个事件的分析、影响评估及未来趋势预测，适合决策参考。'
      };
    });
  }
  
  // 关闭生成报告弹窗
  void closeReportDialog() {
    state.isGeneratingReport.value = false;
    state.reportGenerationStatus.value = ReportGenerationStatus.none;
    // 退出批量选择模式
    batchCheck();
  }
  
  // 预览报告
  void previewReport() {
    Get.snackbar(
      '提示', 
      '正在预览报告',
      backgroundColor: Colors.white,
      colorText: Color(0xFF1A1A1A),
      snackPosition: SnackPosition.BOTTOM,
    );
    closeReportDialog();
  }
  
  // 下载报告
  void downloadReport() {
    Get.snackbar(
      '提示', 
      '正在下载报告',
      backgroundColor: Colors.white,
      colorText: Color(0xFF1A1A1A),
      snackPosition: SnackPosition.BOTTOM,
    );
    closeReportDialog();
  }
  
  // 取消选择
  void cancelSelection() {
    state.selectedItems.clear();
    state.isBatchCheck.value = false;
  }
}
