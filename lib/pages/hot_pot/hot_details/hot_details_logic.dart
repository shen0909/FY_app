import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/models/news_detail_data.dart';
import 'package:safe_app/models/news_effect_company.dart';
import 'package:safe_app/pages/hot_pot/hot_details/hot_details_state.dart';
import 'package:safe_app/utils/dialog_utils.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'package:safe_app/utils/file_utils.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:safe_app/styles/colors.dart';

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

  /// 导出舆情热点新闻报告
  Future<void> downloadFile() async {
    // 检查是否有新闻UUID
    final uuid = state.newsId.value;
    if (uuid.isEmpty) {
      print('导出失败：新闻UUID为空');
      return;
    }
    try {
      // 显示加载对话框
      DialogUtils.showLoading('正在导出报告');
      // 调用API获取下载链接
      final downloadUrl = await ApiService().exportNewsReport(uuid: uuid);
      // 隐藏加载对话框
      DialogUtils.hideLoading();
      if (downloadUrl == null || downloadUrl.isEmpty) {
        // 导出失败
        ToastUtil.showShort('导出失败');
        return;
      }
      // 显示成功对话框
      DialogUtils.showCustomDialog(
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 成功图标
              Container(
                width: 64.w,
                height: 64.h,
                decoration: const BoxDecoration(
                  color: Color(0xFF3361FE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40.w,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '报告生成成功',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 20.h),
              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _downloadAndPreviewReport(downloadUrl),
                      child: Container(
                        height: 40.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: FYColors.loginBtn,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '下载并预览',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      // 隐藏加载对话框
      DialogUtils.hideLoading();
      print('导出报告失败: $e');
      ToastUtil.showShort('导出失败');
    }
  }

  /// 下载并预览报告
  Future<void> _downloadAndPreviewReport(String link) async {
    // 检查链接是否为空
    if (link.isEmpty) {
      ToastUtil.showShort('暂无下载链接', title: '提示');
      return;
    }

    Get.back(); // 关闭前一个弹窗

    try {
      ToastUtil.showShort('开始下载报告...', title: '下载中');

      final uri = Uri.parse(link);
      String fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '报告.xlsx';

      if (!fileName.toLowerCase().endsWith('.xlsx')) {
        fileName = '$fileName.xlsx';
      }

      // 获取文件保存路径
      final dirPath = await _getDownloadDirectory();
      if (dirPath == null) {
        ToastUtil.showShort('获取存储权限或路径失败', title: '下载失败');
        return;
      }

      final savePath = '$dirPath/$fileName';

      // 下载文件
      await _downloadFile(link, savePath);

      ToastUtil.showShort('报告已下载', title: '成功');

      // 打开文件
      await _openFile(savePath);
    } catch (e) {
      ToastUtil.showShort('下载失败', title: '错误');
    }
  }

  /// 获取下载目录路径
  Future<String?> _getDownloadDirectory() async {
    try {
      return await FileUtil.getDownloadDirectoryPath();
    } catch (e) {
      print('获取下载目录失败: $e');
      return null;
    }
  }

  /// 下载文件
  Future<void> _downloadFile(String url, String savePath) async {
    await Dio().download(
      url,
      savePath,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
      ),
      onReceiveProgress: (count, total) {
        if (total > 0) {
          final percent = (count / total * 100).toStringAsFixed(0);
          print('下载进度: $percent%');
        }
      },
    );
  }

  /// 打开文件
  Future<void> _openFile(String filePath) async {
    await OpenFile.open(filePath);
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

