import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/styles/text_styles.dart';
import 'home_logic.dart';
import 'home_state.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final HomeLogic logic = Get.put(HomeLogic());
  final HomeState state = Get.find<HomeLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 12.0.w, right: 12.w, top: 8.w),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    FYImages.appIcon_32,
                    width: 32.w,
                    height: 32.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'FY APP',
                    style: FYTextStyles.getAppTitle(),
                  )
                ],
              ),
              SizedBox(height: 16.w),
              _buildHeader(),
              SizedBox(height: 16.w),
              _buildRiskWarning(),
              SizedBox(height: 16.w),
              _buildQuickMenu(),
              SizedBox(height: 16.w),
              _buildListUpdate(),
            ],
          ),
        ),
      ),
    );
  }

  // 顶部蓝色标题区域
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 172.w,
      decoration: BoxDecoration(
        image: const DecorationImage(image: AssetImage(FYImages.image_1), fit: BoxFit.contain),
        borderRadius: BorderRadius.all(Radius.circular(20.w)),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 10.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
                SizedBox(width: 5.w),
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w),
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: Colors.white54,
                    shape: BoxShape.circle
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 风险预警卡片
  Widget _buildRiskWarning() {
    return GestureDetector(
      onTap: () => logic.goRisk(),
      child: Container(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 22.w, bottom: 20.w),
        height: 174.w,
        decoration: BoxDecoration(
          image: const DecorationImage(
              image: AssetImage(FYImages.riskyBg), fit: BoxFit.cover),
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.w),
        ),
        child: Column(
          children: [
            Row(
              children: [
                badges.Badge(
                  badgeContent: Text(
                    state.notificationCount.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                  badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
                  child: Image.asset(FYImages.riskIcon),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "风险预警",
                      style: TextStyle(
                        color: Color(0xFF4178D3),
                        fontSize: 18.w,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "实时监控风险，智能预警推送",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.w,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.w),
            Wrap(
              spacing: 8.w,
              children: state.riskType
                  .map((element) => _buildRiskItem(element))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }

  // 风险类型项
  Widget _buildRiskItem(Map<String, dynamic> item) {
    return Container(
      width: 101.w,
      height: 60.w,
      decoration: BoxDecoration(
          color: item['bgColor'],
          borderRadius: BorderRadius.circular(10.w),
          border: Border.all(width: 1.w, color: item['borderColor'])),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item['title'],
            style: TextStyle(
              color: item['borderColor'],
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.04 * 16.sp,
              height: 0.8,
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
          SizedBox(height: 7.55.w,),
          Text(
            "${item['count']}家",
            style: TextStyle(
              color: item['borderColor'],
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.04 * 14.sp,
              height: 0.94,
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        ],
      ),
    );
  }

  // 底部快捷菜单
  Widget _buildQuickMenu() {
    return Wrap(
      spacing: 11.w,
      runSpacing: 10.w,
      children:
          state.homeItemList.map((element) => _buildMenuItem(element)).toList(),
    );
  }

  // 菜单项
  Widget _buildMenuItem(Map<String, dynamic> item) {
    return Container(
      width: 170.w,
      height: 80.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: item['bgColor']),
        borderRadius: BorderRadius.circular(15.w),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(item['image'], width: 32.w, height: 32.w),
            SizedBox(height: 8.w),
            Text(
              item['title'],
              style: TextStyle(
                color: FYColors.color_000000,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                height: 0.8,
                leadingDistribution: TextLeadingDistribution.even,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 清单更新信息
  Widget _buildListUpdate() {
    return Container(
      padding: EdgeInsets.only(top: 17.w, left: 16.w, bottom: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1.w,
            blurRadius: 5.w,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(FYImages.detailList,width: 44.w,height: 44.w,fit: BoxFit.contain,),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "清单",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF222222),
                  height: 0.8.w,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
              SizedBox(height: 14.w),
              Text(
                "${state.listUpdateTime}更新",
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  height: 0.8,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
