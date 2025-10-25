import 'package:get/get.dart';
import '../../../models/login_log_list.dart';

class UserLoginDataState {
  // 登录日志列表 - 使用真实的数据模型
  final RxList<ListElement> loginLogs = <ListElement>[].obs;
  
  // 分页状态
  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 10.obs;
  final RxInt totalCount = 0.obs;
  final RxBool hasMore = true.obs;
  
  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;

  UserLoginDataState() {
    // 不再初始化演示数据，等待从接口获取真实数据
  }

  /// 重置到第一页
  void resetPagination() {
    currentPage.value = 1;
    hasMore.value = true;
    loginLogs.clear();
  }

  /// 添加登录日志数据
  void addLoginLogs(List<ListElement> newLogs, int totalCount) {
    this.totalCount.value = totalCount;
    loginLogs.addAll(newLogs);
    
    // 检查是否还有更多数据
    hasMore.value = loginLogs.length < totalCount;
  }

  /// 刷新登录日志数据（替换现有数据）
  void refreshLoginLogs(List<ListElement> newLogs, int totalCount) {
    this.totalCount.value = totalCount;
    loginLogs.assignAll(newLogs);
    
    // 检查是否还有更多数据
    hasMore.value = loginLogs.length < totalCount;
  }

  /// 格式化时间显示
  String formatDate(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = today.subtract(const Duration(days: 1));
      DateTime logDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (logDate == today) {
        return '今天';
      } else if (logDate == yesterday) {
        return '昨天';
      } else {
        return '${dateTime.month.toString().padLeft(2, '0')}月${dateTime.day.toString().padLeft(2, '0')}日';
      }
    } catch (e) {
      return dateTimeString;
    }
  }

  /// 格式化时间为HH:mm
  String formatTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
}
