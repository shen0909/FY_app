import 'package:get/get.dart';

class UserLoginDataState {
  // 登录日志列表
  final RxList<Map<String, dynamic>> loginLogs = <Map<String, dynamic>>[].obs;

  UserLoginDataState() {
    ///初始化数据
    _initDemoData();
  }

  // 初始化演示数据
  void _initDemoData() {
    // 今天的数据
    loginLogs.addAll([
      {
        'date': '今天',
        'time': '09:35',
        'status': '登录成功',
        'isSuccess': true,
        'device': 'iPhone 13 Pro',
        'location': '广东省深圳市',
        'ip': '192.168.1.1'
      },
      {
        'date': '今天',
        'time': '09:35',
        'status': '登录成功',
        'isSuccess': true,
        'device': 'iPhone 13 Pro',
        'location': '广东省深圳市',
        'ip': '192.168.1.1'
      }
    ]);

    // 昨天的数据
    loginLogs.addAll([
      {
        'date': '昨天',
        'time': '09:35',
        'status': '登录成功',
        'isSuccess': true,
        'device': 'iPhone 13 Pro',
        'location': '广东省深圳市',
        'ip': '192.168.1.1'
      },
      {
        'date': '昨天',
        'time': '09:35',
        'status': '登录失败',
        'isSuccess': false,
        'device': 'iPhone 13 Pro',
        'location': '广东省深圳市',
        'ip': '192.168.1.1',
        'reason': '密码错误'
      }
    ]);

    // 05月05日
    loginLogs.addAll([
      {
        'date': '05月05日',
        'time': '09:35',
        'status': '登录成功',
        'isSuccess': true,
        'device': 'iPhone 13 Pro',
        'location': '广东省深圳市',
        'ip': '192.168.1.1'
      }
    ]);

    // 05月04日
    loginLogs.addAll([
      {
        'date': '05月04日',
        'time': '09:35',
        'status': '登录成功',
        'isSuccess': true,
        'device': 'iPhone 13 Pro',
        'location': '广东省深圳市',
        'ip': '192.168.1.1'
      }
    ]);

    // 05月03日
    loginLogs.addAll([
      {
        'date': '05月03日',
        'time': '09:35',
        'status': '登录成功',
        'isSuccess': true,
        'device': 'iPhone 13 Pro',
        'location': '广东省深圳市',
        'ip': '192.168.1.1'
      }
    ]);
  }
}
