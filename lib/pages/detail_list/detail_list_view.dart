import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/main.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';

import 'detail_list_logic.dart';
import 'detail_list_state.dart';

/// 清单信息
class DetailListPage extends StatelessWidget {
  DetailListPage({Key? key}) : super(key: key);

  final DetailListLogic logic = Get.put(DetailListLogic());
  final DetailListState state = Get.find<DetailListLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FYColors.whiteColor,
      appBar: FYAppBar(title: '清单列表'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(),
          _buildFilterSection(),
          _buildFilterChips(),
          _buildResultCount(),
          _buildTableHeader(),
          Expanded(
            child: _buildCompanyList(),
          ),
        ],
      ),
    );
  }
  
  // 信息区域
  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text(
            "当前总数：${state.totalCount}",
            style: TextStyle(
              fontSize: 12.sp,
              color: FYColors.color_A6A6A6,
              fontWeight: FontWeight.normal,
            ),
          )),
          Text(
            "更新时间：2025-05-15",
            style: TextStyle(
              fontSize: 12.sp,
              color: FYColors.color_A6A6A6,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  // 筛选条件区域
  Widget _buildFilterSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
      child: Row(
        children: [
          Text(
            "筛选条件",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: FYColors.color_1A1A1A,
            ),
          ),
          const Spacer(),
          Container(
            width: 197.w,
            decoration: BoxDecoration(
              color: FYColors.whiteColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FYColors.color_E6E6E6),
            ),
            child: Row(
              children: [
                Image.asset(FYImages.search_icon,width: 20.w,height: 20.w,fit: BoxFit.contain,),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: '请输入企业名称',
                      hintStyle: TextStyle(
                        color: FYColors.color_A6A6A6,
                        fontSize: 14.sp,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => logic.search(value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 筛选标签区域
  Widget _buildFilterChips() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip("类型", state.typeFilter.value, () => _showFilterDialog("类型")),
          const SizedBox(width: 12),
          _buildFilterChip("省份", state.provinceFilter.value, () => _showFilterDialog("省份")),
          const SizedBox(width: 12),
          _buildFilterChip("城市", state.cityFilter.value, () => _showFilterDialog("城市")),
        ],
      ),
    );
  }
  
  // 筛选按钮
  Widget _buildFilterChip(String title, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFF1A1A1A),
            ),
          ],
        ),
      ),
    );
  }
  
  // 显示筛选对话框
  void _showFilterDialog(String type) {
    // 实际开发中这里应该根据类型不同显示不同的选项
    List<String> options = [];
    
    if (type == "类型") {
      options = ["EL", "NS-CMIC", "CMC", "Non-SDN CMIC", "SSI", "UVL", "DPL"];
    } else if (type == "省份") {
      options = ["广东", "北京", "上海", "浙江", "安徽", "香港"];
    } else if (type == "城市") {
      options = ["广州", "深圳", "北京", "上海", "杭州", "合肥", "香港"];
    }
    
    Get.dialog(
      AlertDialog(
        title: Text("选择$type"),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(options[index]),
                onTap: () {
                  if (type == "类型") {
                    logic.setTypeFilter(options[index]);
                  } else if (type == "省份") {
                    logic.setProvinceFilter(options[index]);
                  } else if (type == "城市") {
                    logic.setCityFilter(options[index]);
                  }
                  Get.back();
                },
              );
            },
          ),
        ),
      ),
    );
  }
  
  // 结果数量
  Widget _buildResultCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => Text(
        "${state.companyList.length} 条结果",
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF3361FE),
          fontWeight: FontWeight.normal,
        ),
      )),
    );
  }
  
  // 表格头部
  Widget _buildTableHeader() {
    return Container(
      height: 28,
      color: Color(0xFFF0F5FF),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              "序号",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF3361FE),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "名称",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF3361FE),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              "制裁类型",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF3361FE),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              "地区",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF3361FE),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 企业列表
  Widget _buildCompanyList() {
    return Obx(() {
      if (state.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      
      return ListView.separated(
        itemCount: state.companyList.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = state.companyList[index];
          final isOdd = index % 2 == 1;
          
          return Container(
            color: isOdd ? Colors.white : Color(0xFFF9F9F9),
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    "${item.id}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A1A1A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: _buildSanctionTypeTag(item.sanctionType),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    item.region,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
  
  // 构建制裁类型标签
  Widget _buildSanctionTypeTag(String type) {
    Color bgColor;
    Color textColor;
    
    switch (type) {
      case 'EL':
        bgColor = Color(0xFFFFECE9);
        textColor = Color(0xFFFF2A08);
        break;
      case 'NS-CMIC':
      case 'Non-SDN CMIC':
        bgColor = Color(0xFFFFF7E9);
        textColor = Color(0xFFFFA408);
        break;
      case 'CMC':
      case 'SSI':
        bgColor = Color(0xFFE7FEF8);
        textColor = Color(0xFF07CC89);
        break;
      case 'UVL':
      case 'DPL':
      default:
        bgColor = Color(0xFFEDEDED);
        textColor = Color(0xFF1A1A1A);
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
