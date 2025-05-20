import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/routers/routers.dart';

import 'home_state.dart';

class HomeLogic extends GetxController {
  final HomeState state = HomeState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  // 去风险预警页
  void goRisk(){
    Get.toNamed(Routers.risk);
  }

  // 去热点页
  void goHotPot() {
    Get.toNamed(Routers.hotPot);
  }

  // 导航到AI问答页面
  void goAiQus() {
    Get.toNamed(Routers.aiQus);
  }
  
  // 导航到订阅管理页面
  void goOrder() {
    Get.toNamed(Routers.order);
  }

  // 导航到系统设置页面
  Future<void> goSetting() async {
    try {
      final result = await ApiService().getRegion();
      if (result != null) {
        print('获取地区参数成功: $result');
      } else {
        print('获取地区参数失败: 返回为空');
      }
    } catch (e) {
      print('获取地区参数异常: $e');
    } finally {
      // 无论API调用成功还是失败，都跳转到设置页面
      Get.toNamed(Routers.setting);
    }
  }

  goDetailList() {
    Get.toNamed(Routers.detailList);
  }
}
