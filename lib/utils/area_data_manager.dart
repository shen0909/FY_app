import 'dart:convert';
import 'package:flutter/services.dart';

/// 省市数据管理器
class AreaDataManager {
  static AreaDataManager? _instance;
  static AreaDataManager get instance => _instance ??= AreaDataManager._();
  
  AreaDataManager._();

  Map<String, String>? _provinceList;
  Map<String, String>? _cityList;
  bool _isLoaded = false;

  /// 加载省市数据
  Future<void> loadAreaData() async {
    if (_isLoaded) return;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/area-data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _provinceList = Map<String, String>.from(jsonData['province_list'] ?? {});
      _cityList = Map<String, String>.from(jsonData['city_list'] ?? {});
      
      _isLoaded = true;
      print('省市数据加载成功: ${_provinceList?.length}个省份, ${_cityList?.length}个城市');
    } catch (e) {
      print('加载省市数据失败: $e');
      _provinceList = {};
      _cityList = {};
    }
  }

  /// 获取省份列表（包含"全部"选项）
  List<String> getProvinceList() {
    if (!_isLoaded || _provinceList == null) {
      return ['全部'];
    }
    
    List<String> provinces = ['全部'];
    // provinces.addAll(_provinceList!.values.toList()..sort());
    provinces.addAll(_provinceList!.values.toList());
    return provinces;
  }

  /// 根据省份名称获取该省份下的城市列表
  List<String> getCityListByProvince(String provinceName) {
    if (!_isLoaded || _cityList == null || provinceName == '全部') {
      return ['全部'];
    }
    
    // 先找到省份对应的编码
    String? provinceCode;
    for (var entry in _provinceList!.entries) {
      if (entry.value == provinceName) {
        provinceCode = entry.key;
        break;
      }
    }
    
    if (provinceCode == null) {
      return ['全部'];
    }
    
    // 根据省份编码前缀筛选城市
    String provincePrefix = provinceCode.substring(0, 2);
    List<String> cities = ['全部'];
    
    for (var entry in _cityList!.entries) {
      String cityCode = entry.key;
      if (cityCode.startsWith(provincePrefix)) {
        cities.add(entry.value);
      }
    }
    
    // 城市列表排序（保持"全部"在首位）
    List<String> sortedCities = cities.sublist(1)..sort();
    return cities;
  }

  /// 根据城市名称获取其所属省份
  String? getProvinceByCity(String cityName) {
    if (!_isLoaded || _cityList == null || _provinceList == null || cityName == '全部') {
      return null;
    }
    
    // 找到城市对应的编码
    String? cityCode;
    for (var entry in _cityList!.entries) {
      if (entry.value == cityName) {
        cityCode = entry.key;
        break;
      }
    }
    
    if (cityCode == null) return null;
    
    // 根据城市编码前缀找到省份
    String provincePrefix = cityCode.substring(0, 2) + '0000';
    return _provinceList![provincePrefix];
  }

  /// 获取所有城市列表（不分省份，包含"全部"选项）
  List<String> getAllCities() {
    if (!_isLoaded || _cityList == null) {
      return ['全部'];
    }
    
    List<String> cities = ['全部'];
    cities.addAll(_cityList!.values.toList());
    return cities;
  }

  /// 检查数据是否已加载
  bool get isLoaded => _isLoaded;

  /// 获取省份数量
  int get provinceCount => _provinceList?.length ?? 0;

  /// 获取城市数量  
  int get cityCount => _cityList?.length ?? 0;
} 