import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'detail_list_state.dart';

class DetailListLogic extends GetxController {
  final DetailListState state = DetailListState();
  
  // 添加滚动控制器
  late final ScrollController horizontalScrollController;
  late final ScrollController leftVerticalController;
  late final ScrollController rightVerticalController;

  @override
  void onInit() {
    super.onInit();
    // 初始化滚动控制器
    horizontalScrollController = ScrollController();
    leftVerticalController = ScrollController();
    rightVerticalController = ScrollController();
    
    // 设置滚动同步
    setupScrollControllers();
  }

  @override
  void onReady() {
    // 初始化数据
    loadData();
    super.onReady();
  }

  @override
  void onClose() {
    // 释放滚动控制器资源
    horizontalScrollController.dispose();
    leftVerticalController.dispose();
    rightVerticalController.dispose();
    super.onClose();
  }
  
  // 设置滚动控制器
  void setupScrollControllers() {
    leftVerticalController.addListener(syncRightScroll);
    rightVerticalController.addListener(syncLeftScroll);
  }
  
  // 同步右侧滚动到左侧
  void syncRightScroll() {
    if (leftVerticalController.offset != rightVerticalController.offset) {
      rightVerticalController.jumpTo(leftVerticalController.offset);
    }
  }
  
  // 同步左侧滚动到右侧
  void syncLeftScroll() {
    if (rightVerticalController.offset != leftVerticalController.offset) {
      leftVerticalController.jumpTo(rightVerticalController.offset);
    }
  }
  
  // 加载清单数据
  void loadData() {
    state.isLoading.value = true;
    
    // 模拟网络请求延迟
    Future.delayed(const Duration(milliseconds: 800), () {
      // 模拟数据 - 实际项目中应从API获取
      state.companyList.value = _getMockData();
      state.totalCount.value = state.companyList.length;
      state.isLoading.value = false;
    });
  }
  
  // 搜索
  void search(String keyword) {
    state.searchText.value = keyword;
    // 实际应用中这里应该调用API搜索
    // 这里简单模拟过滤本地数据
    loadData();
  }
  
  // 设置类型筛选
  void setTypeFilter(String type) {
    state.typeFilter.value = type;
    // 重新加载数据
    loadData();
  }
  
  // 设置省份筛选
  void setProvinceFilter(String province) {
    state.provinceFilter.value = province;
    // 重新加载数据
    loadData();
  }
  
  // 设置城市筛选
  void setCityFilter(String city) {
    state.cityFilter.value = city;
    // 重新加载数据
    loadData();
  }
  
  // 清除所有筛选条件
  void clearFilters() {
    state.typeFilter.value = '';
    state.provinceFilter.value = '';
    state.cityFilter.value = '';
    state.searchText.value = '';
    // 重新加载数据
    loadData();
  }
  
  // 模拟数据
  List<CompanyItem> _getMockData() {
    return [
      CompanyItem(id: 1, name: '华为技术有限公司', sanctionType: 'EL', region: '广东'),
      CompanyItem(id: 2, name: '中芯国际集成电路制造有限公司', sanctionType: 'EL', region: '上海'),
      CompanyItem(id: 3, name: '字节跳动有限公司', sanctionType: 'NS-CMIC', region: '北京'),
      CompanyItem(id: 4, name: '大疆创新科技有限公司', sanctionType: 'CMC', region: '广东'),
      CompanyItem(id: 5, name: '海康威视数字技术股份有限公司', sanctionType: 'Non-SDN CMIC', region: '浙江'),
      CompanyItem(id: 6, name: '科大讯飞股份有限公司', sanctionType: 'SSI', region: '安徽'),
      CompanyItem(id: 7, name: '商汤科技有限公司', sanctionType: 'EL', region: '香港'),
      CompanyItem(id: 8, name: '旷视科技有限公司', sanctionType: 'UVL', region: '北京'),
      CompanyItem(id: 9, name: '北京云从科技有限公司', sanctionType: 'UVL', region: '北京'),
      CompanyItem(id: 10, name: '深信服科技股份有限公司', sanctionType: 'DPL', region: '广东'),
    ];
  }
}
