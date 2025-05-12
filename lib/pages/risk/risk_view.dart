import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'risk_logic.dart';
import 'risk_state.dart';

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
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
            ),
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
        children: [
          Expanded(
            child: _buildUnitTypeButton('一类单位', 0),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildUnitTypeButton('二类单位', 1),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey.shade700,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$count家',
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '较昨日调整了$change家',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 总数统计卡片
  Widget _buildTotalStatCard({
    required int total,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '总数',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$total家',
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 19), // 占位，使高度与其他卡片一致
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
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
