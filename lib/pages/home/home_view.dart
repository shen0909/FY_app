import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;

import 'home_logic.dart';
import 'home_state.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final HomeLogic logic = Get.put(HomeLogic());
  final HomeState state = Get.find<HomeLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("首页"),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildRiskWarning(),
          _buildQuickMenu(),
          _buildListUpdate(),
        ],
      ),
    );
  }

  // 顶部蓝色标题区域
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3079DE), Color(0xFF296BD8)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "观察：",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "措施 (${state.observationDate})",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 15),
          // 底部小圆点指示器
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white54,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white54,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 风险预警卡片
  Widget _buildRiskWarning() {
    return GestureDetector(
      onTap: () => logic.goRisk(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 15, 15, 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            badges.Badge(
              badgeContent: Text(
                state.notificationCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.red,
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4178D3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                       Text(
                        "风险预警",
                        style: TextStyle(
                          color: Color(0xFF4178D3),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "实时监控风险，智能预警推送",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRiskItem("高风险", state.highRiskCount, Colors.red.shade100, Colors.red),
                      _buildRiskItem("中风险", state.mediumRiskCount, Colors.orange.shade100, Colors.orange),
                      _buildRiskItem("低风险", state.lowRiskCount, Colors.green.shade100, Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 风险类型项
  Widget _buildRiskItem(String title, int count, Color bgColor, Color textColor) {
    return Container(
      // width: 90,
      // height: 70,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "$count家",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 底部快捷菜单
  Widget _buildQuickMenu() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMenuItem(
                  onTap: () => logic.goHotPot(),
                  title: "热点",
                  icon: Icons.trending_up,
                  bgColor: Colors.red.shade400,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildMenuItem(
                  title: "AI问答",
                  icon: Icons.smart_toy_outlined,
                  bgColor: Colors.blue.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildMenuItem(
                  title: "我的订阅",
                  icon: Icons.notifications_outlined,
                  bgColor: Colors.orange,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildMenuItem(
                  title: "系统设置",
                  icon: Icons.settings,
                  bgColor: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 菜单项
  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 清单更新信息
  Widget _buildListUpdate() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "清单",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${state.listUpdateTime}更新",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
