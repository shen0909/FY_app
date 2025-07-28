import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/https/api_service.dart';
import '../../../models/order_event_model.dart';

import 'order_event_detial_state.dart';

class OrderEventDetialLogic extends GetxController {
  final OrderEventDetialState state = OrderEventDetialState();
  final ApiService _apiService = ApiService();
  
  // 添加变量来标识当前是事件还是专题
  bool _isEvent = true;
  OrderEventModels? _currentModel;

  @override
  void onReady() {
    super.onReady();
    // 获取路由参数
    final Map<String, dynamic>? args = Get.arguments;
    if (args != null) {
      // 处理新的参数格式
      if (args.containsKey('is_event') && args.containsKey('models')) {
        _isEvent = args['is_event'] as bool;
        _currentModel = args['models'] as OrderEventModels;
        // 根据模型数据初始化基本信息
        _initializeFromModel(_currentModel!);
        // 根据是否是事件来加载对应的详情和动态
        if (_isEvent) {
          loadEventDetailsByUuid(_currentModel!.uuid);
        } else {
          loadTopicDetailsByUuid(_currentModel!.uuid);
        }
      }
      // 兼容旧的参数格式
      else if (args.containsKey('eventTitle')) {
        loadEventDetails(args['eventTitle']);
      } else if (args.containsKey('eventUuid')) {
        loadEventDetailsByUuid(args['eventUuid']);
      }
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
  
  // 从模型数据初始化基本信息
  void _initializeFromModel(OrderEventModels model) {
    state.eventTitle.value = model.name;
    state.eventUuid.value = model.uuid;
    state.eventDescription.value = model.description ?? '';
    state.isFollowed.value = model.isFollowed;
    state.eventTags.addAll(model.keyword);
  }
  
  // 通过UUID加载事件详情
  Future<void> loadEventDetailsByUuid(String eventUuid) async {
    try {
      // 显示加载状态
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      await loadEventLatestUpdates(eventUuid);
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
  
  // 通过UUID加载专题详情
  Future<void> loadTopicDetailsByUuid(String topicUuid) async {
    try {
      // 显示加载状态
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      
      // 并行获取专题详情和最新动态
      await loadTopicLatestUpdates(topicUuid);
      
      // 关闭加载对话框
      Get.back();
    } catch (e) {
      Get.back(); // 关闭加载对话框
      Get.snackbar(
        '错误', 
        '加载专题详情失败: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 加载事件最新动态
  Future<void> loadEventLatestUpdates(String eventUuid) async {
    try {
      final result = await _apiService.getEventLatestUpdates(
        eventUuid: eventUuid,
        currentPage: 1,
        pageSize: 10,
      );
      
      if (result != null && result['执行结果'] == true) {
        final Map<String, dynamic> returnData = result['返回数据'] ?? {};
        final List<dynamic> updatesData = returnData['list'] ?? [];
        
        state.latestUpdates.clear();
        
        for (var update in updatesData) {
          state.latestUpdates.add({
            'uuid': update['uuid'] ?? '',
            'title': update['title'] ?? '',
            'content': update['summary'] ?? '', // 使用summary作为内容
            'date': update['publish_time'] ?? '',
            'type': update['types'] ?? '',
            'source': update['news_medium'] ?? '',
          });
        }
        print('✅ 成功加载事件最新动态，共 ${state.latestUpdates.length} 条');
      } else {
        print('❌ 加载事件最新动态失败: ${result?['返回消息'] ?? '未知错误'}');
      }
    } catch (e) {
      print('❌ 加载事件最新动态异常: $e');
    }
  }
  
  // 加载专题最新动态
  Future<void> loadTopicLatestUpdates(String topicUuid) async {
    try {
      final result = await _apiService.getTopicLatestUpdates(
        eventUuid: topicUuid, // API方法中参数名为eventUuid但实际可以传入topicUuid
        currentPage: 1,
        pageSize: 10, // 增加获取更多数据
      );
      
      if (result != null && result['执行结果'] == true) {
        // 根据实际返回数据结构解析
        final Map<String, dynamic> returnData = result['返回数据'] ?? {};
        final List<dynamic> updatesData = returnData['list'] ?? [];
        
        state.latestUpdates.clear();
        
        for (var update in updatesData) {
          state.latestUpdates.add({
            'uuid': update['uuid'] ?? '',
            'title': update['title'] ?? '',
            'content': update['summary'] ?? '', // 使用summary作为内容
            'date': update['publish_time'] ?? '',
            'type': update['types'] ?? '',
            'source': update['news_medium'] ?? '',
          });
        }
        
        print('✅ 成功加载专题最新动态，共 ${state.latestUpdates.length} 条');
      } else {
        print('❌ 加载专题最新动态失败: ${result?['返回消息'] ?? '未知错误'}');
      }
    } catch (e) {
      print('❌ 加载专题最新动态异常: $e');
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
      if (_isEvent) {
        await loadEventDetailsByUuid(state.eventUuid.value);
      } else {
        await loadTopicDetailsByUuid(state.eventUuid.value);
      }
    }
  }
  
  // 关注/取消关注事件或专题
  Future<void> toggleEventFollow() async {
    try {
      // 根据是否是事件来调用不同的API
      if (_isEvent) {
        // 调用事件关注API
        final result = await _apiService.toggleEventSubscription(
          subjectUuid: state.eventUuid.value,
          isFollow: !state.isFollowed.value,
        );
        
        if (result != null && result['执行结果'] == true) {
          if (state.isFollowed.value) {
            state.isFollowed.value = false;
            state.followCount.value--;
            Get.snackbar('成功', '已取消关注该事件');
          } else {
            state.isFollowed.value = true;
            state.followCount.value++;
            Get.snackbar('成功', '已关注该事件');
          }
        } else {
          Get.snackbar('错误', '操作失败');
        }
      } else {
        // 调用专题关注API
        final result = await _apiService.toggleTopicSubscription(
          subjectUuid: state.eventUuid.value,
          isFollow: state.isFollowed.value,
        );
        
        if (result != null && result['执行结果'] == true) {
          if (state.isFollowed.value) {
            state.isFollowed.value = false;
            state.followCount.value--;
            Get.snackbar('成功', '已取消关注该专题');
          } else {
            state.isFollowed.value = true;
            state.followCount.value++;
            Get.snackbar('成功', '已关注该专题');
          }
        } else {
          Get.snackbar('错误', '操作失败');
        }
      }
    } catch (e) {
      Get.snackbar('错误', '操作失败: $e');
    }
  }
  
  // 获取当前页面标题（用于UI显示）
  String getPageTitle() {
    return _isEvent ? '事件详情' : '专题详情';
  }
  
  // 获取关注按钮文本
  String getFollowButtonText() {
    if (_isEvent) {
      return state.isFollowed.value ? '已关注事件' : '关注事件';
    } else {
      return state.isFollowed.value ? '已关注专题' : '关注专题';
    }
  }
  
  // 判断当前是否为事件
  bool get isEvent => _isEvent;
}
