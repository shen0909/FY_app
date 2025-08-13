import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:safe_app/https/api_service.dart';
import '../../../models/order_event_model.dart';
import '../../../routers/routers.dart';
import '../../../utils/datetime_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:open_file/open_file.dart';
import '../../../utils/docx_export_util.dart';
import 'order_event_detial_state.dart';

class OrderEventDetialLogic extends GetxController {
  final OrderEventDetialState state = OrderEventDetialState();
  final ApiService _apiService = ApiService();
  
  // 添加变量来标识当前是事件还是专题
  bool _isEvent = true;
  OrderEventModels? _currentModel;

  Timer? _pollTimer; // 当前查询导出结果的计时器
  String? _currentExportUuid; // 当前导出的uuid

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
    // 结束时停止轮询
    _pollTimer?.cancel();
    super.onClose();
  }
  
  // 从模型数据初始化基本信息
  void _initializeFromModel(OrderEventModels model) {
    state.eventTitle.value = model.name;
    state.eventUuid.value = model.uuid;
    state.eventDescription.value = model.description ?? '';
    state.isFollowed.value = model.isFollowed;
    state.eventTags.addAll(model.keyword);
    // 重置分页状态
    state.currentPage.value = 1;
    state.hasMoreData.value = true;
    state.isLoadingMore.value = false;
    state.totalCount.value = 0;
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
  Future<void> loadEventLatestUpdates(String eventUuid, {bool isLoadMore = false}) async {
    try {
      // 如果是加载更多，设置加载状态
      if (isLoadMore) {
        state.isLoadingMore.value = true;
      }
      
      final result = await _apiService.getEventLatestUpdates(
        eventUuid: eventUuid,
        currentPage: isLoadMore ? state.currentPage.value : 1,
        pageSize: state.pageSize,
      );
      
      if (result != null && result['执行结果'] == true) {
        final Map<String, dynamic> returnData = result['返回数据'] ?? {};
        final List<dynamic> updatesData = returnData['list'] ?? [];
        final int allCount = returnData['all_count'] ?? 0;
        if (!isLoadMore) {
          state.latestUpdates.clear();
          state.currentPage.value = 1;
          state.totalCount.value = allCount;
        }
        // 添加新数据
        for (var update in updatesData) {
          state.latestUpdates.add({
            'uuid': update['uuid'] ?? '',
            'title': update['title'] ?? '',
            'content': update['summary'] ?? '',
            'date': DateTimeUtils.formatDetailTime(update['publish_time']),
            'type': update['types'] ?? '',
            'source': update['news_medium'] ?? '',
          });
        }
        
        // 更新分页状态
        if (isLoadMore) {
          state.currentPage.value++;
        }
        // 判断是否还有更多数据
        state.hasMoreData.value = state.latestUpdates.length < allCount;
        print('✅ 成功加载事件最新动态，当前共 ${state.latestUpdates.length} 条，总共 $allCount 条');
      } else {
        print('❌ 加载事件最新动态失败: ${result?['返回消息'] ?? '未知错误'}');
      }
    } catch (e) {
      print('❌ 加载事件最新动态异常: $e');
    } finally {
      if (isLoadMore) {
        state.isLoadingMore.value = false;
      }
    }
  }
  
  // 加载专题最新动态
  Future<void> loadTopicLatestUpdates(String topicUuid, {bool isLoadMore = false}) async {
    try {
      // 如果是加载更多，设置加载状态
      if (isLoadMore) {
        state.isLoadingMore.value = true;
      }
      
      final result = await _apiService.getTopicLatestUpdates(
        eventUuid: topicUuid,
        currentPage: isLoadMore ? state.currentPage.value : 1,
        pageSize: state.pageSize,
      );
      
      if (result != null && result['执行结果'] == true) {
        final Map<String, dynamic> returnData = result['返回数据'] ?? {};
        final List<dynamic> updatesData = returnData['list'] ?? [];
        final int allCount = returnData['all_count'] ?? 0;
        
        // 如果不是加载更多，清空现有数据并重置页码
        if (!isLoadMore) {
          state.latestUpdates.clear();
          state.currentPage.value = 1;
          state.totalCount.value = allCount;
        }
        
        // 添加新数据
        for (var update in updatesData) {
          state.latestUpdates.add({
            'uuid': update['uuid'] ?? '',
            'title': update['title'] ?? '',
            'content': update['summary'] ?? '',
            'date': DateTimeUtils.formatDetailTime(update['publish_time']),
            'type': update['types'] ?? '',
            'source': update['news_medium'] ?? '',
          });
        }
        
        // 更新分页状态
        if (isLoadMore) {
          state.currentPage.value++;
        }
        
        // 判断是否还有更多数据
        state.hasMoreData.value = state.latestUpdates.length < allCount;
        
        print('✅ 成功加载专题最新动态，当前共 ${state.latestUpdates.length} 条，总共 $allCount 条');
      } else {
        print('❌ 加载专题最新动态失败: ${result?['返回消息'] ?? '未知错误'}');
      }
    } catch (e) {
      print('❌ 加载专题最新动态异常: $e');
    } finally {
      if (isLoadMore) {
        state.isLoadingMore.value = false;
      }
    }
  }
  
  // 加载更多动态
  Future<void> loadMoreUpdates() async {
    if (state.isLoadingMore.value || !state.hasMoreData.value) {
      return;
    }
    if (state.eventUuid.value.isNotEmpty) {
      if (_isEvent) {
        await loadEventLatestUpdates(state.eventUuid.value, isLoadMore: true);
      } else {
        await loadTopicLatestUpdates(state.eventUuid.value, isLoadMore: true);
      }
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
    Get.toNamed(Routers.hotDetails, arguments: {
      'newsId': update['uuid'],
      'title': update['title']
    });
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
  Future<void> generateReport() async {
    if (state.selectedItems.isEmpty) {
      Get.snackbar('提示', '请先选择要生成报告的项目');
      return;
    }

    // 打开生成报告弹窗，展示“生成中”
    state.isGeneratingReport.value = true;
    state.reportGenerationStatus.value = ReportGenerationStatus.generating;

    try {
      // 取已选新闻UUID
      final List<String> newsUuids = state.selectedItems
          .map((i) => (i >= 0 && i < state.latestUpdates.length)
              ? (state.latestUpdates[i]['uuid'] as String? ?? '')
              : '')
          .where((e) => e.isNotEmpty)
          .toList();

      if (newsUuids.isEmpty) {
        state.reportGenerationStatus.value = ReportGenerationStatus.failed;
        Get.snackbar('错误', '未获取到可用的UUID');
        return;
      }

      final String type = _isEvent ? '事件' : '专题';
      final String typeName = state.eventTitle.value;

      // 发起导出
      final recordUuid = await _apiService.startExportReport(
        type: type,
        typeName: typeName,
        newsUuids: newsUuids,
      );
      // 发起导出失败
      if (recordUuid == null || recordUuid.isEmpty) {
        state.reportGenerationStatus.value = ReportGenerationStatus.failed;
        Get.snackbar('错误', '提交导出失败');
        return;
      }
      // 发起导出成功
      _currentExportUuid = recordUuid;

      // 先查一次结果
      final bool finished = await _queryAndUpdate(recordUuid);
      if (finished) return; // 已完成

      // 未完成则轮询，直至完成/失败/超时
      int tries = 0;
      const int maxTries = 60; // 约2分钟
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        tries++;
        final done = await _queryAndUpdate(recordUuid);
        if (done || tries >= maxTries) {
          if (tries >= maxTries && state.reportGenerationStatus.value == ReportGenerationStatus.generating) {
            state.reportGenerationStatus.value = ReportGenerationStatus.failed;
            Get.snackbar('超时', '报告生成超时，请稍后重试');
          }
          timer.cancel();
        }
      });
    } catch (e) {
      state.reportGenerationStatus.value = ReportGenerationStatus.failed;
      Get.snackbar('错误', '生成报告失败: $e');
    }
  }

  /// 查询一次导出结果并更新状态，返回是否已完成（成功或失败）
  Future<bool> _queryAndUpdate(String uuid) async {
    final data = await _apiService.queryExportReportResult(uuid: uuid);
    if (data == null) return false;
    final int? status = data['status'] is int ? data['status'] as int : int.tryParse('${data['status']}');
    // 成功
    if (status == 2) {
      state.reportInfo.value = {
        'title': data['file_name'] ?? '报告',
        'file_name': data['file_name'] ?? '报告.docx',
        'download_link': data['download_link'] ?? '',
        'fileType': 'docx',
        'date': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        'items': state.selectedItems.length,
        'eventName': state.eventTitle.value,
      };
      state.reportGenerationStatus.value = ReportGenerationStatus.success;
      return true;
    }
    if (status == 3) {
      state.reportGenerationStatus.value = ReportGenerationStatus.failed;
      return true;
    }
    // 仍在处理中
    state.reportGenerationStatus.value = ReportGenerationStatus.generating;
    return false;
  }

  // 导出选中项目为DOCX文件
  Future<void> exportToDocx() async {
    if (state.selectedItems.isEmpty) {
      Get.snackbar('提示', '请先选择要导出的项目');
      return;
    }

    // 显示加载对话框
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '正在导出DOCX文件...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '选中项目: ${state.selectedItems.length} 个',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // 执行导出
      final filePath = await DocxExportUtil.exportEventUpdatesToDocx(
        state.eventTitle.value,
        state.latestUpdates,
        state.selectedItems,
      );

      // 关闭加载对话框
      Get.back();

      if (filePath != null) {
        // 导出成功，显示确认对话框
        Get.dialog(
          AlertDialog(
            title: const Text('导出成功'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('已成功导出 ${state.selectedItems.length} 个项目'),
                const SizedBox(height: 12),
                Text(
                  '文件已保存到：\n$filePath',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  // 导出成功后可以选择性地清空选中项目
                  state.selectedItems.clear();
                  state.isBatchCheck.value = false;
                },
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // 关闭加载对话框
      Get.back();
      
      // 显示错误信息
      Get.dialog(
        AlertDialog(
          title: const Text('导出失败'),
          content: Text('导出过程中出现错误：\n$e'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }
  
  // 取消选择模式
  void cancelSelection() {
    state.selectedItems.clear();
    state.isBatchCheck.value = false;
  }
  
  // 关闭报告对话框
  void closeReportDialog() {
    state.isGeneratingReport.value = false; // 关闭弹层
    state.reportGenerationStatus.value = ReportGenerationStatus.none;
    state.reportInfo.clear();
  }
  
  // 预览报告（直接打开下载链接）
  void previewReport() async {
    final link = state.reportInfo['download_link']?.toString() ?? '';
    if (link.isEmpty) {
      Get.snackbar('提示', '暂无可预览的报告链接');
      return;
    }
    final lower = link.toLowerCase();
    final isDoc = lower.endsWith('.doc') || lower.endsWith('.docx');
    final previewUrl = isDoc
        ? 'https://view.officeapps.live.com/op/view.aspx?src=${Uri.encodeComponent(link)}'
        : link;
    await launchUrlString(previewUrl, mode: LaunchMode.externalApplication);
  }
  
  // 下载报告：保存到本地临时目录并调起系统应用打开
  Future<void> downloadReport() async {
    final link = state.reportInfo['download_link']?.toString() ?? '';
    if (link.isEmpty) {
      Get.snackbar('提示', '暂无下载链接');
      return;
    }
    try {
      Get.snackbar('下载中', '开始下载报告...');
      // 文件名优先用后端返回，其次从URL截取
      String fileName = (state.reportInfo['file_name']?.toString() ?? '').trim();
      if (fileName.isEmpty) {
        final uri = Uri.parse(link);
        fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '报告.docx';
      }
      final savePath = await DocxExportUtil.getExportFilePath(fileName);

      await Dio().download(
        link,
        savePath,
        options: Options(responseType: ResponseType.bytes, followRedirects: true),
        onReceiveProgress: (count, total) {
          if (total > 0) {
            final percent = (count / total * 100).toStringAsFixed(0);
            // 可在此对接到UI进度条，如需要
            // print('下载进度: $percent%');
          }
        },
      );

      final finalPath = await DocxExportUtil.ensurePublicVisibility(savePath, fileName);
      Get.snackbar('成功', '报告已下载：$finalPath');
      await OpenFile.open(finalPath);
    } catch (e) {
      Get.snackbar('下载失败', '$e');
    }
  }
  
  // 刷新数据
  Future<void> refreshData() async {
    // 重置分页状态
    state.currentPage.value = 1;
    state.hasMoreData.value = true;
    state.isLoadingMore.value = false;
    
    if (state.eventUuid.value.isNotEmpty) {
      if (_isEvent) {
        await loadEventLatestUpdates(state.eventUuid.value);
      } else {
        await loadTopicLatestUpdates(state.eventUuid.value);
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
