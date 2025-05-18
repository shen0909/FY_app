import 'package:get/get.dart';

class PrivacySafeState {
  // 隐私数据保护开关状态
  final RxBool isDataEncryptionEnabled = true.obs;
  final RxBool isAutoDeleteEnabled = false.obs;
  final RxBool isThirdPartyShareDisabled = true.obs;
  final RxBool isPrivacyModeEnabled = false.obs;
  
  // 隐私政策版本
  final String privacyPolicyVersion = "v3.0.0";
  final String lastUpdated = "2024-05-10";
  
  // 隐私政策内容
  final String privacyVideoDescription = "本视频全面介绍系统的核心功能和使用流程，帮助新用户快速上手。";

  // 收集的信息内容
  final List<String> collectedInfoItems = [
    "账户信息：用户名、密码等",
    "登录信息：登录时间、IP地址、设备信息等",
    "使用记录：操作日志、访问内容、使用频率等",
    "系统交互：订阅内容、AI问答记录等",
  ];

  // 信息使用内容
  final List<String> infoUsageItems = [
    "提供、维护和改进系统服务",
    "进行身份验证和安全防护",
    "分析使用情况以优化用户体验",
    "遵守法律法规要求",
  ];

  // 信息保护内容
  final List<String> infoProtectionItems = [
    "数据加密传输与存储",
    "访问控制和权限管理",
    "定期安全审计和评估",
    "员工保密培训和管理",
  ];

  // 信息存储内容
  final String infoStorageDescription = "所有数据存储在符合国家安全标准的服务器中，部分敏感数据会进行特殊加密处理。系统会根据法律要求和业务需要设置合理的数据保存期限。";
  
  // 数据保护详情
  final List<Map<String, dynamic>> dataProtectionItems = [
    {
      'title': '数据加密存储',
      'description': '所有敏感数据均采用高强度加密算法存储，确保数据安全。',
      'enabled': true,
    },
    {
      'title': '自动清除痕迹',
      'description': '系统可定期自动清除您的浏览记录和临时文件，减少数据泄露风险。',
      'enabled': false,
    },
    {
      'title': '禁止第三方共享',
      'description': '严格控制您的数据不会被分享给任何第三方机构或应用。',
      'enabled': true,
    },
    {
      'title': '隐私浏览模式',
      'description': '开启后系统不会记录您的浏览历史和搜索记录。',
      'enabled': false,
    },
  ];

  PrivacySafeState() {
    ///Initialize variables
  }
}
