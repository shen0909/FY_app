import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/models/news_detail_data.dart';
import 'package:safe_app/models/news_effect_company.dart';
import 'package:safe_app/pages/hot_pot/hot_details/hot_details_state.dart';
import 'package:safe_app/utils/dialog_utils.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'package:safe_app/utils/docx_export_util.dart';

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
    // 区分首次加载与下拉刷新
    if (!state.hasLoadedOnce.value) {
      state.isLoading.value = true;
    } else {
      state.isRefreshing.value = true;
    }
    state.errorMessage.value = '';
    
    try {
      print('正在获取新闻ID: ${state.newsId.value} 的详情');
      final result = await ApiService().getNewsDetail(newsId: state.newsId.value);
      
      // 检查API响应状态
      if (result != null && result['code'] == 10010 && result['data'] != null) {
        state.newsDetail.value = result['data'];
        
        try {
          // 尝试转换为类型化的NewsDetail对象
          print('开始转换NewsDetail对象');
          state.newsDetailData.value = NewsDetail.fromJson(result['data']);
          print('NewsDetail对象转换成功');
          // 获取新闻详情成功后，自动获取影响企业数据
          await fetchEffectCompanyData();
        } catch (conversionError) {
          // 捕获数据转换错误
          print('数据转换错误: $conversionError');
          state.errorMessage.value = '数据格式错误: $conversionError';
          if (state.isRefreshing.value) {
            ToastUtil.showShort('刷新失败，请检查网络后重试');
          }
        }
        // 成功后标记已加载
        state.hasLoadedOnce.value = true;
      } else {
        // API响应错误
        print('API响应错误: ${result?['msg'] ?? '未知错误'}');
        state.errorMessage.value = result?['msg'] ?? '获取新闻详情失败';
        if (state.isRefreshing.value) {
          ToastUtil.showShort('刷新失败，请检查网络后重试');
        }
      }
    } catch (e) {
      // 网络或其他错误
      print('请求异常: $e');
      state.errorMessage.value = '网络异常，请检查网络后重试';
      if (state.isRefreshing.value) {
        ToastUtil.showShort('刷新失败，请检查网络后重试');
      }
    } finally {
      state.isLoading.value = false;
      state.isRefreshing.value = false;
    }
  }

  // 切换标签页
  void changeTab(int index) {
    state.activeTabIndex.value = index;
  }

  /// 获取新闻影响企业数据
  Future<void> fetchEffectCompanyData({bool isRefresh = false}) async {
    if (state.newsId.value.isEmpty) {
      print('新闻ID为空，无法获取影响企业数据');
      return;
    }

    if (isRefresh) {
      // 刷新时重置分页状态
      state.effectCompanyCurrentPage.value = 1;
      state.effectCompanyList.clear();
      state.hasMoreEffectCompany.value = true;
    }

    if (state.isLoadingEffectCompany.value || !state.hasMoreEffectCompany.value) {
      return;
    }

    state.isLoadingEffectCompany.value = true;
    state.effectCompanyErrorMessage.value = '';

    try {
      print('正在获取新闻影响企业数据，页码: ${state.effectCompanyCurrentPage.value}');
      
      final result = await ApiService().getNewsEffectCompany(
        newsUuid: state.newsId.value,
        currentPage: state.effectCompanyCurrentPage.value,
        pageSize: state.effectCompanyPageSize.value,
        // effectType: null, // 暂时不传影响类型，获取所有类型
      );
      if (result != null && result['code'] == 10010 && result['data'] != null) {
        final responseData = result['data'];
        
        try {
          if (responseData is List) {
            // 直接处理列表数据
            List<EffectCompany> effectCompanies = responseData
                .map((element) => EffectCompany.fromJson(element))
                .toList();
            
            if (isRefresh) {
              state.effectCompanyList.clear();
            }
            
            // 添加新的企业数据
            state.effectCompanyList.addAll(effectCompanies);
            state.effectCompanyTotalCount.value = effectCompanies.length;
            state.hasMoreEffectCompany.value = false;
            
            print('成功获取影响企业数据，总数: ${effectCompanies.length}, 当前列表长度: ${state.effectCompanyList.length}');
          }
        } catch (e) {
          print('解析影响企业数据失败: $e');
          state.effectCompanyErrorMessage.value = '数据解析失败';
        }
      } else {
        print('获取影响企业数据失败: ${result?['msg'] ?? '未知错误'}');
        state.effectCompanyErrorMessage.value = result?['msg'] ?? '获取数据失败';
      }
    } catch (e) {
      print('获取影响企业数据异常: $e');
      state.effectCompanyErrorMessage.value = '网络异常，请重试';
    } finally {
      state.isLoadingEffectCompany.value = false;
    }
  }

  /// 加载更多影响企业数据（新接口没有分页，此方法保留但不再使用）
  Future<void> loadMoreEffectCompanyData() async {
    // 新接口返回所有数据，不需要分页加载
    print('新接口不支持分页加载，所有数据已在首次请求中返回');
  }

  /// 刷新影响企业数据
  Future<void> refreshEffectCompanyData() async {
    await fetchEffectCompanyData(isRefresh: true);
  }

  // 下载相关文件
  Future<void> downloadFile() async {
    // 检查是否有详情数据
    if (state.newsDetailData.value == null) {
      ToastUtil.showShort('暂无可导出的数据');
      return;
    }
    // 显示加载对话框
    DialogUtils.showLoading('正在导出DOCX文件');

    try {
      // 执行导出 - 传递新的影响企业数据
      final filePath = await DocxExportUtil.exportNewsDetailToDocx(
        state.newsDetailData.value!,
        effectCompanyList: state.effectCompanyList.toList(),
      );
      // 关闭加载对话框
      DialogUtils.hideLoading();

      if (filePath != null) {
        // 导出成功，显示确认对话框
        Get.dialog(
          AlertDialog(
            title: const Text('导出成功'),
            content: Text('文件已保存到：\n$filePath'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      } else {
        // 导出失败（包括权限被拒绝），显示错误提示
        // Get.dialog(
        //   AlertDialog(
        //     title: const Text('导出失败'),
        //     content: const Text('导出失败，请检查存储权限或重试'),
        //     actions: [
        //       TextButton(
        //         onPressed: () => Get.back(),
        //         child: const Text('确定'),
        //       ),
        //     ],
        //   ),
        // );
      }
    } catch (e) {
      // 关闭加载对话框
      DialogUtils.hideLoading();
      
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

  // 复制内容
  void copyContent(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ToastUtil.showShort('内容已复制到剪贴板', title: '复制成功');
  }

  // 分享内容
  void shareContent() {
    // 实际应用中这里会调用分享API
    ToastUtil.showShort('分享功能已触发', title: '分享提示');
  }

  // 添加到收藏
  void addToFavorites() {
    // 实际应用中这里会实现收藏功能
    ToastUtil.showShort('已添加到收藏', title: '收藏提示');
  }

  changeTranslate(int index) {
    state.activeTranslateIndex.value = index;
  }
}

