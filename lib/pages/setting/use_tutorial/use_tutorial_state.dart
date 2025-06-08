import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../styles/image_resource.dart';

class UseTutorialState {
  // 当前选中的标签索引
  final RxInt selectedTabIndex = 0.obs;
  
  // 视频播放状态
  final RxBool isPlaying = false.obs;
  final RxDouble currentProgress = 0.0.obs;
  
  // 视频教程列表
  final RxList<Map<String, dynamic>> videoTutorials = <Map<String, dynamic>>[].obs;
  
  // 基础功能列表
  final RxList<Map<String, dynamic>> basicTutorials = <Map<String, dynamic>>[].obs;
  
  // 高级功能列表
  final RxList<Map<String, dynamic>> advancedTutorials = <Map<String, dynamic>>[].obs;

  RxBool isExpandAi = false.obs;
  RxBool isExpandPermission = false.obs;
  RxBool isExpandData = false.obs;

  UseTutorialState() {
    ///Initialize variables
    _initData();
  }
  
  // 初始化数据
  void _initData() {
    // 初始化视频教程列表
    videoTutorials.addAll([
      {
        'title': '系统功能概览',
        'description': '本视频全面介绍系统的核心功能和使用流程，帮助新用户快速上手。',
        'duration': '5:20',
        'thumbnail': 'assets/images/video_thumbnail1.png',
        'requiresPermission': false
      },
      {
        'title': '事件订阅详解',
        'description': '详细讲解如何筛选、订阅和管理事件，以获取最相关的信息。',
        'duration': '3:45',
        'thumbnail': 'assets/images/video_thumbnail1.png',
        'requiresPermission': false
      },
      {
        'title': 'AI问答高级技巧',
        'description': '掌握高效使用AI问答功能的方法，包括提示词优化和专业问题构建。',
        'duration': '7:12',
        'thumbnail': 'assets/images/video_thumbnail1.png',
        'requiresPermission': false
      },
      {
        'title': '管理员功能培训',
        'description': '为管理员提供的专业培训视频，讲解高级管理功能和权限设置。',
        'duration': '10:35',
        'thumbnail': 'assets/images/video_thumbnail1.png',
        'requiresPermission': true
      },
    ]);
    
    // 初始化基础功能教程
    basicTutorials.addAll([
      {
        'title': '开始使用',
        'icon_path' : FYImages.start_use,
        'description': '欢迎使用重点企业态势感知预警系统。系统主要包括以下功能模块：\n1. 事件中心：浏览和订阅事件信息\n2. 态势分析：查看企业态势和风险评估\n3. AI问答：智能分析和解答问题\n4. 个人设置：管理账户和权限\n点击下方"查看详情"按钮学习如何使用各个功能。'
      },
      {
        'title': '事件中心使用指南',
        'icon_path' : FYImages.event_tutorial,
        'description': '事件中心是系统的核心功能，提供企业相关事件的实时更新和订阅服务。',
        'features': [
          '事件订阅：订阅感兴趣的事件类型',
          '专题订阅：关注特定主题的事件集合',
          '我的关注：管理已收藏的事件和专题'
        ]
      },
      {
        'title': '态势分析使用指南',
        'icon_path' : FYImages.analyse_tutorial,
        'description': '态势分析模块帮助您了解企业发展态势和潜在风险。',
        'features': [
          {'title': '风险评估', 'description': '分析企业面临的各类风险和警示'},
          {'title': '趋势预测', 'description': '预测企业发展趋势和行业变化'}
        ]
      }
    ]);
    
    // 初始化高级功能教程
    advancedTutorials.addAll([
      {
        'title': 'AI问答功能',
        'description': 'AI问答功能允许您与系统智能助手进行对话，获取信息和分析。',
        'tips': [
          '使用清晰具体的问题获得更准确的回答',
          '可以询问企业数据、市场分析和风险评估',
          '支持连续对话，系统会记住上下文',
          '聊天记录保留7天后自动清除'
        ],
        'steps': [
          '进入AI问答页面',
          '在底部输入框中输入您的问题',
          '点击发送按钮或按回车键提交问题',
          '等待AI助手回答'
        ],
        'templates': ['企业风险分析', '市场趋势预测', '政策解读', '数据可视化']
      },
      {
        'title': '权限管理',
        'description': '系统采用三级权限管理机制，确保数据安全和操作合规。',
        'roles': [
          {'name': '管理员', 'description': '系统最高权限，可进行所有操作，但敏感操作需经审核员审核'},
          {'name': '审核员', 'description': '负责审核管理员的操作，确保系统安全'},
          {'name': '普通用户', 'description': '基本浏览和使用权限'}
        ],
        'process': [
          '在个人资料页面进入"权限管理"',
          '选择"申请权限"并填写理由',
          '等待审核员审核',
          '审核通过后权限自动更新'
        ]
      },
      {
        'title': '数据导出功能',
        'description': '系统支持多种格式的数据导出，方便您进行离线分析和报告生成。',
        'formats': ['PDF', 'Excel', 'Word', 'CSV']
      }
    ]);
  }
}
