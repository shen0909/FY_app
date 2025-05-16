import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';

import 'risk_logic.dart';
import 'risk_state.dart';
import 'package:safe_app/styles/text_styles.dart';

class RiskPage extends StatelessWidget {
  RiskPage({Key? key}) : super(key: key);

  final RiskLogic logic = Get.put(RiskLogic());
  final RiskState state = Get.find<RiskLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '风险预警',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationSection(),
          _buildUnitTypeSelector(),
          _buildRiskStatCards(),
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
          Text(
            state.location,
            style: FYTextStyles.riskLocationTitleStyle(),
          ),
        ],
      ),
    );
  }

  // 单位类型选择器
  Widget _buildUnitTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildUnitTypeButton('一类单位', 0),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: _buildUnitTypeButton('二类单位', 1),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: _buildUnitTypeButton('星云', 1),
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
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(colors: [Color(0xFF345DFF), Color(0xFF2F89F8)])
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
      padding: const EdgeInsets.all(8.0),
      child: Obx(() {
        final currentData = state.currentUnitData;
        return Wrap(
          spacing: 8.0, // 横向间距
          runSpacing: 8.0, // 纵向间距
          children: [
            ...currentData.entries.where((entry) => entry.key != 'total').map((entry) {
              final item = entry.value;
              return SizedBox(
                width: MediaQuery.of(Get.context!).size.width / 2 - 16,
                child: _buildRiskStatCard(
                  title: item['title'],
                  count: item['count'],
                  change: item['change'],
                  color: Color(item['color']),
                ),
              );
            }),

            // 总数卡片单独处理
            SizedBox(
              width: MediaQuery.of(Get.context!).size.width / 2 - 16,
              child: _buildTotalStatCard(
                total: currentData['total']['count'],
                color: Color(currentData['total']['color']),
              ),
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
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(8),
      color: const Color(0xffF4F4F4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
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
                      style: FYTextStyles.riskStatHighRiskStyle().copyWith(
                        color: FYColors.color_1A1A1A,
                        fontSize: 28.sp
                      ),
                    ),
                    Text(
                      '家',
                      style: FYTextStyles.riskStatHighRiskStyle().copyWith(color: FYColors.color_1A1A1A)
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4.w),
            RichText(
                text: TextSpan(
                  style: TextStyle(
                      color: FYColors.color_A6A6A6,
                      fontSize: 12
                  ),
                  children:[
                    TextSpan(text: '较昨日调整了'),
                    TextSpan(text: '$change',
                        style: TextStyle(
                        color: Colors.red,
                        fontSize: 12.sp
                    ),
                    ),
                    TextSpan(text: '家'),
                ]
                ))
          ],
        ),
      ),
    );
  }

  // 总数统计卡片
  Widget _buildTotalStatCard({
    required int total,
    required Color color
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(8),
      color: const Color(0xffF4F4F4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      style: FYTextStyles.riskStatHighRiskStyle().copyWith(
                          color: FYColors.color_1A1A1A,
                          fontSize: 28.sp
                      ),
                    ),
                    Text(
                        '家',
                        style: FYTextStyles.riskStatHighRiskStyle().copyWith(color: FYColors.color_1A1A1A)
                    ),
                  ],
                ),
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
          padding: const EdgeInsets.all(8),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            return state.chooseUint.value == 0
                ? _buildRiskItem1(currentList[index])  // 一类单位
                : _buildRiskItem2(currentList[index]); // 二类单位
          },
        );
      }),
    );
  }

  // 一类单位风险项
  Widget _buildRiskItem1(Map<String, dynamic> item) {
    final bool isHighRisk = item['riskLevel'] == '高风险';
    final Color riskColor = Color(item['riskColor']);
    final bool isRead = item['isRead'] as bool;

    return GestureDetector(
      onTap: () => Get.toNamed('/risk/details', arguments: item),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isHighRisk ? Colors.red.shade100 : Colors.green.shade100,
            width: 1,
          ),
        ),
        color: isHighRisk ? Colors.red.shade50 : Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.green.shade100 : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isRead ? '全部已读' : '',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item['englishName'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['description'],
                style: FYTextStyles.riskCompanyDescStyle(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        item['riskLevel'],
                        style: TextStyle(
                          fontSize: 12,
                          color: riskColor,
                          fontWeight: FontWeight.bold,
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
    final Color bgColor = Color(item['bgColor']);
    final int unreadCount = item['unreadCount'];

    return GestureDetector(
      onTap: () => Get.toNamed('/risk/details', arguments: item),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      unreadCount > 0 ? '$unreadCount条未读' : '',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item['englishName'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['description'],
                style: FYTextStyles.riskCompanyDescStyle(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        item['riskLevel'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
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
