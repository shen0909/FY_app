import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../https/api_service.dart';
import '../../../models/login_log_list.dart';
import '../../../utils/toast_util.dart';
import 'user_login_data_state.dart';

class UserLoginDataLogic extends GetxController {
  final UserLoginDataState state = UserLoginDataState();

  @override
  void onReady() {
    super.onReady();
    // 加载登录日志数据
    loadLoginLogs();
  }

  @override
  void onClose() {
    super.onClose();
  }
  
  /// 加载登录日志数据（首次加载）
  Future<void> loadLoginLogs() async {
    if (state.isLoading.value) return;
    
    state.isLoading.value = true;
    // 首次加载时清空数据并重置分页
    state.resetPagination();
    
    try {
      final result = await ApiService().getLoginLogList(
        currentPage: state.currentPage.value,
        pageSize: state.pageSize.value,
      );
      
      if (kDebugMode) {
        print('获取登录日志列表结果: $result');
      }
      
      if (result != null && result['执行结果'] == true) {
        final returnData = result['返回数据'];
        if (returnData != null) {
          final loginLogList = LoginLogList.fromJson(returnData);
          state.refreshLoginLogs(loginLogList.list, loginLogList.allCount);
          
          if (kDebugMode) {
            print('成功加载 ${loginLogList.list.length} 条登录日志，总共 ${loginLogList.allCount} 条');
          }
        }
      } else {
        if (kDebugMode) {
          print('登录日志列表接口返回数据异常: ${result?['错误信息'] ?? '未知错误'}');
        }
        ToastUtil.showShort('获取登录日志失败，请稍后重试', title: '提示');
      }
    } catch (e) {
      if (kDebugMode) {
        print('获取登录日志列表失败: $e');
      }
      ToastUtil.showShort('网络请求失败，请检查网络连接', title: '提示');
    } finally {
      state.isLoading.value = false;
    }
  }
  
  /// 下拉刷新
  Future<void> onRefresh() async {
    if (state.isRefreshing.value) return;
    
    state.isRefreshing.value = true;
    // 不清空数据，只重置分页参数
    state.currentPage.value = 1;
    state.hasMore.value = true;
    
    try {
      final result = await ApiService().getLoginLogList(
        currentPage: state.currentPage.value,
        pageSize: state.pageSize.value,
      );
      
      if (result != null && result['执行结果'] == true) {
        final returnData = result['返回数据'];
        if (returnData != null) {
          final loginLogList = LoginLogList.fromJson(returnData);
          // 刷新成功后，替换所有数据
          state.refreshLoginLogs(loginLogList.list, loginLogList.allCount);
          
          if (kDebugMode) {
            print('刷新成功，获取到 ${loginLogList.list.length} 条数据');
          }
        }
      } else {
        if (kDebugMode) {
          print('刷新登录日志接口返回数据异常: ${result?['错误信息'] ?? '未知错误'}');
        }
        ToastUtil.showShort('刷新失败，请稍后重试', title: '提示');
      }
    } catch (e) {
      if (kDebugMode) {
        print('刷新登录日志失败: $e');
      }
      ToastUtil.showShort('网络请求失败，请检查网络连接', title: '提示');
    } finally {
      state.isRefreshing.value = false;
    }
  }
  
  /// 加载更多日志
  Future<void> loadMoreLogs() async {
    if (state.isLoadingMore.value || !state.hasMore.value) return;
    
    state.isLoadingMore.value = true;
    state.currentPage.value++;
    
    try {
      final result = await ApiService().getLoginLogList(
        currentPage: state.currentPage.value,
        pageSize: state.pageSize.value,
      );
      
      if (result != null && result['执行结果'] == true) {
        final returnData = result['返回数据'];
        if (returnData != null) {
          final loginLogList = LoginLogList.fromJson(returnData);
          state.addLoginLogs(loginLogList.list, loginLogList.allCount);
          
          if (kDebugMode) {
            print('加载更多成功，当前页: ${state.currentPage.value}，总条数: ${state.loginLogs.length}');
          }
        }
      } else {
        // 加载失败，回退页数
        state.currentPage.value--;
        ToastUtil.showShort('加载更多失败，请稍后重试', title: '提示');
      }
    } catch (e) {
      // 加载失败，回退页数
      state.currentPage.value--;
      if (kDebugMode) {
        print('加载更多登录日志失败: $e');
      }
      ToastUtil.showShort('网络请求失败，请检查网络连接', title: '提示');
    } finally {
      state.isLoadingMore.value = false;
    }
  }

  /// 获取按日期分组的登录日志
  Map<String, List<ListElement>> getGroupedLogs() {
    Map<String, List<ListElement>> result = {};
    for (var log in state.loginLogs) {
      String date = state.formatDate(log.createdAt);
      if (!result.containsKey(date)) {
        result[date] = [];
      }
      result[date]!.add(log);
    }
    
    return result;
  }
}
