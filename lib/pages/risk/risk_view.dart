import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/widgets/widgets.dart';

import '../../widgets/custom_app_bar.dart';
import 'risk_logic.dart';
import 'risk_state.dart';
import 'package:safe_app/styles/text_styles.dart';

class RiskPage extends StatefulWidget {
  const RiskPage({Key? key}) : super(key: key);

  @override
  State<RiskPage> createState() => _RiskPageState();
}

class _RiskPageState extends State<RiskPage> {
  final RiskLogic logic = Get.put(RiskLogic());
  final RiskState state = Get.find<RiskLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FYColors.whiteColor,
      appBar: FYAppBar(
        title: '风险预警',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationSection(),
          _buildUnitTypeSelector(),
          _buildRiskStatCards(),
          SizedBox(height: 14.w),
          _buildRiskList(),
        ],
      ),
    );
  }

  // 地区信息区域
  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            key: logic.locationKey,
            onTap: () => logic.showCitySelector(context),
            child: Row(
              children: [
                Obx(() => Text(
                  state.location.value,
                  style: FYTextStyles.riskLocationTitleStyle(),
                )),
                const SizedBox(width: 8),
                Image.asset(FYImages.down_icon, width: 8.w, height: 8.w, fit: BoxFit.contain,),
              ],
            ),
          ),
          const Spacer(),
          Container(
            width: 180.w,
            decoration: BoxDecoration(
              color: FYColors.whiteColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FYColors.color_E6E6E6),
            ),
            child: Row(
              children: [
                SizedBox(width: 8.w),
                Image.asset(FYImages.search_icon, width: 20.w,
                  height: 20.w,
                  fit: BoxFit.contain,),
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
                    onChanged: (value) {
                      print("风险预警--value ${value}");
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 单位类型选择器
  Widget _buildUnitTypeSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 11.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildUnitTypeButton('烽云一号', 0),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: _buildUnitTypeButton('烽云二号', 1),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: _buildUnitTypeButton('星云', 2),
          ),
        ],
      ),
    );
  }

  // 单位类型按钮
  Widget _buildUnitTypeButton(String title, int index) {
    return Obx(() {
      final isSelected = state.chooseUint.value == index;
      return GestureDetector(
        onTap: () => logic.changeUnit(index),
        child: Container(
          height: 36.w,
          width: 108.w,
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF345DFF), Color(0xFF2F89F8)])
                : null,
            color: isSelected ? null : const Color(0xFFF0F5FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: isSelected
                  ? FYTextStyles.riskUnitTypeSelectedStyle()
                  : FYTextStyles.riskUnitTypeUnselectedStyle(),
            ),
          ),
        ),
      );
    });
  }

  // 风险统计卡片区域
  Widget _buildRiskStatCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final currentData = state.currentUnitData.value;
        return Wrap(
          spacing: 7.0.w, // 横向间距
          runSpacing: 8.0.w, // 纵向间距
          children: [
            ...currentData.entries
                .where((entry) => entry.key != 'total')
                .map((entry) {
              final item = entry.value;
              return _buildRiskStatCard(
                title: item['title'],
                count: item['count'],
                change: item['change'],
                color: Color(item['color']),
              );
            }),
            // 总数卡片单独处理
            _buildTotalStatCard(
              total: currentData['total']['count'],
              color: Color(currentData['total']['color']),
            ),
          ],
        );
      }),
    );
  }

  // 风险统计卡片
  Widget _buildRiskStatCard({
    required String title,
    required int count,
    required int change,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffF4F4F4),
        borderRadius: BorderRadius.circular(8.w),
      ),
      // elevation: 0,
      padding: EdgeInsets.all(10.w),
      // color: Colors.red,
      width: 168.w,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: FYTextStyles.riskStatHighRiskStyle(),
              ),
              Row(
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      color: FYColors.color_1A1A1A,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Text('家',
                      style: FYTextStyles.riskStatHighRiskStyle().copyWith(
                          color: FYColors.color_1A1A1A,
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp)),
                ],
              ),
            ],
          ),
          SizedBox(height: 4.h),
          RichText(
              text: TextSpan(
                  style: TextStyle(
                    color: FYColors.color_A6A6A6,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    height: 0.8,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                  children: [
                const TextSpan(text: '较昨日调整了'),
                TextSpan(
                  text: '$change',
                  style: const TextStyle(color: Colors.red),
                ),
                const TextSpan(text: '家'),
              ]))
        ],
      ),
    );
  }

  // 总数统计卡片
  Widget _buildTotalStatCard({required int total, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffF4F4F4),
        borderRadius: BorderRadius.circular(8.w),
      ),
      // elevation: 0,
      padding: EdgeInsets.all(10.r),
      // color: Colors.red,
      height: 64.w,
      width: 168.w,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '总数',
              style: FYTextStyles.riskStatHighRiskStyle(),
            ),
            Row(
              children: [
                Text(
                  '$total',
                  style: TextStyle(
                    color: FYColors.color_1A1A1A,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
                Text('家',
                    style: FYTextStyles.riskStatHighRiskStyle().copyWith(
                        color: FYColors.color_1A1A1A,
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 风险单位列表
  Widget _buildRiskList() {
    return Expanded(
      child: Obx(() {
        final currentList = state.currentRiskList;
        return ListView.builder(
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            return state.chooseUint.value == 0
                ? _buildRiskItem1(currentList[index]) // 一类单位
                : state.chooseUint.value == 1
                    ? _buildRiskItem2(currentList[index])
                    : _buildRiskItem2(currentList[index]); // 二类单位
          },
        );
      }),
    );
  }

  // 一类单位风险项
  Widget _buildRiskItem1(Map<String, dynamic> item) {
    final String riskLevel = item['riskLevel'];
    final Color riskColor = Color(item['riskColor']);
    final bool isRead = item['isRead'] as bool;

    // 根据风险等级设置背景色和边框颜色
    Color backgroundColor;
    Color borderColor;
    
    switch (riskLevel) {
      case '高风险':
        backgroundColor = Color(0xFFFFECE9);
        borderColor = Color(0xFFFF6850);
        break;
      case '中风险':
        backgroundColor = Color(0xFFFFF7E6);
        borderColor = Color(0xFFF6D500);
        break;
      case '低风险':
        backgroundColor = Color(0xFFE7FEF8);
        borderColor = Color(0xFF07CC89);
        break;
      default:
        backgroundColor = Color(0xFFE7FEF8);
        borderColor = Color(0xFF07CC89);
    }

    return GestureDetector(
      onTap: () => Get.toNamed('/risk/details', arguments: item),
      child: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 10.w),
        child: Container(
          width: 343.w,
          padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: 16.w),
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(8.w)),
              border: Border.all(width: 1.w, color: borderColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['name'],
                      style: FYTextStyles.riskCompanyTitleStyle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: isRead ? null : () => logic.showMessageDialog(item['id']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isRead
                            ? FYColors.color_CEFFEE
                            : FYColors.color_FFD8D2,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isRead ? '全部已读' : '${item['unreadCount']}条未读',
                        style: TextStyle(
                          color: isRead
                              ? FYColors.color_07CC89
                              : FYColors.color_FF2A08,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.w),
              Text(
                item['englishName'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FYTextStyles.commonTextStyle(),
              ),
              const SizedBox(height: 8),
              Text(
                item['description'],
                style: FYTextStyles.commonTextStyle(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.w),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '更新: ${item['updateTime']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '风险等级: ',
                        style: FYTextStyles.commonTextStyle(),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.w)),
                            color: FYColors.whiteColor),
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 6.w),
                        child: Text(
                          item['riskLevel'],
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: riskColor,
                            height: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 二类单位风险项
  Widget _buildRiskItem2(Map<String, dynamic> item) {
    final String riskLevel = item['riskLevel'];
    final Color riskColor = Color(item['riskColor']);
    final bool isRead = item['isRead'] as bool;

    // 根据风险等级设置背景色和边框颜色
    Color backgroundColor;
    Color borderColor;
    
    switch (riskLevel) {
      case '高风险':
        backgroundColor = Color(0xFFFFECE9);
        borderColor = Color(0xFFFF6850);
        break;
      case '中风险':
        backgroundColor = Color(0xFFFFF7E6);
        borderColor = Color(0xFFF6D500);
        break;
      case '低风险':
        backgroundColor = Color(0xFFE7FEF8);
        borderColor = Color(0xFF07CC89);
        break;
      default:
        backgroundColor = Color(0xFFE7FEF8);
        borderColor = Color(0xFF07CC89);
    }

    return GestureDetector(
      onTap: () => Get.toNamed('/risk/details', arguments: item),
      child: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 10.w),
        child: Container(
          width: 343.w,
          padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: 16.w),
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(8.w)),
              border: Border.all(width: 1.w, color: borderColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['name'],
                      style: FYTextStyles.riskCompanyTitleStyle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: isRead ? null : () => logic.showMessageDialog(item['id']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            isRead ? FYColors.color_CEFFEE : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isRead ? '全部已读' : '',
                        style: TextStyle(
                          color: isRead
                              ? FYColors.color_07CC89
                              : Colors.transparent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.w),
              Text(
                item['englishName'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FYTextStyles.commonTextStyle(),
              ),
              const SizedBox(height: 8),
              Text(
                item['description'],
                style: FYTextStyles.commonTextStyle(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.w),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '更新: ${item['updateTime']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '风险等级: ',
                        style: FYTextStyles.commonTextStyle(),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.w)),
                            color: FYColors.whiteColor),
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 6.w),
                        child: Text(
                          item['riskLevel'],
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: riskColor,
                            height: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
