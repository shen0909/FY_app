import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/styles/text_styles.dart';
import 'dart:convert';
import 'home_logic.dart';
import 'home_state.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final HomeLogic logic = Get.put(HomeLogic());
  final HomeState state = Get.find<HomeLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FYColors.color_F6F8FC,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 12.0.w, right: 12.w, top: 8.h),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      FYImages.appIcon_32,
                      width: 32.w,
                      height: 32.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'FY APP',
                      style: FYTextStyles.getAppTitle(),
                    )
                  ],
                ),
                SizedBox(height: 16.h),
                _buildHeader(),
                SizedBox(height: 16.h),
                _buildRiskWarning(),
                SizedBox(height: 16.h),
                _buildQuickMenu(),
                SizedBox(height: 16.h),
                _buildListUpdate(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 顶部轮播图区域
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 172.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12.r)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20.r)),
        child: Stack(
          children: [
            // 轮播图
            GetBuilder<HomeLogic>(
              builder: (controller) {
                return Obx(() {
                  // 优先使用接口数据，如果没有则使用默认数据
                  final bannerCount = state.bannerList.isNotEmpty 
                      ? state.bannerList.length 
                      : state.carouselItems.length;
                  
                  if (bannerCount == 0) {
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Text('暂无轮播图数据'),
                      ),
                    );
                  }
                  return PageView.builder(
                    controller: controller.pageController,
                    itemCount: bannerCount,
                    onPageChanged: (index) {
                      logic.updateBannerIndex(index);
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => logic.onBannerTap(index),
                        child: Container(
                          width: double.infinity,
                          child: Stack(
                            children: [
                              _buildBannerImage(index),
                              // 文字遮罩层（渐变背景）
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(15.w, 30.h, 15.w, 15.h),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.topRight,
                                      colors: [
                                        Color(0xff85000000),
                                        Color(0xff00000000),
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    _getBannerTitle(index),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                });
              }
            ),
            // 轮播图指示器 - 修改为动态数量
            Positioned(
              bottom: 10.h,
              right: 16.w,
              child: GetBuilder<HomeLogic>(
                builder: (controller) {
                  return Obx(() {
                    final bannerCount = state.bannerList.isNotEmpty 
                        ? state.bannerList.length 
                        : state.carouselItems.length;
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(bannerCount, (index) {
                        return Container(
                          width: 8.w,
                          height: 8.w,
                          margin: EdgeInsets.symmetric(horizontal: 2.5.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: state.currentBannerIndex == index
                                ? Colors.white
                                : Colors.white54,
                          ),
                        );
                      }),
                    );
                  });
                }
              ),
            )
          ],
        ),
      ),
    );
  }

  // 构建轮播图图片
  Widget _buildBannerImage(int index) {
    // 优先使用接口数据
    if (state.bannerList.isNotEmpty && index < state.bannerList.length) {
      final banner = state.bannerList[index];
      if (banner.image.isNotEmpty) {
        try {
          // 解析base64图片
          final bytes = base64Decode(banner.image);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 172.h,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(Icons.image_not_supported),
                ),
              );
            },
          );
        } catch (e) {
          // base64解析失败，显示占位图
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: Icon(Icons.image_not_supported),
            ),
          );
        }
      }
    }
    
    // 使用默认数据
    if (state.carouselItems.isNotEmpty && index < state.carouselItems.length) {
      final item = state.carouselItems[index];
      return Image.asset(
        item.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 172.h,
      );
    }
    
    // 兜底显示
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.image),
      ),
    );
  }

  // 获取轮播图标题
  String _getBannerTitle(int index) {
    // 优先使用接口数据
    if (state.bannerList.isNotEmpty && index < state.bannerList.length) {
      return state.bannerList[index].title;
    }
    
    // 使用默认数据
    if (state.carouselItems.isNotEmpty && index < state.carouselItems.length) {
      return state.carouselItems[index].title;
    }
    
    return '暂无标题';
  }

  // 风险预警卡片
  Widget _buildRiskWarning() {
    return GestureDetector(
      onTap: () => logic.goRisk(),
      child: Container(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 22.h, bottom: 20.h),
        decoration: BoxDecoration(
          image: const DecorationImage(image: AssetImage(FYImages.riskyBg), fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(15.r),
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
                        color: FYColors.color_1D4293,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "实时监控风险，智能预警推送",
                      style: TextStyle(
                        color: FYColors.color_555555,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _buildRiskItem(state.riskType[0])),
                SizedBox(width: 8.w),
                Expanded(child: _buildRiskItem(state.riskType[1])),
                SizedBox(width: 8.w),
                Expanded(child: _buildRiskItem(state.riskType[2])),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 风险类型项
  Widget _buildRiskItem(Map<String, dynamic> item) {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
          color: item['bgColor'],
          borderRadius: BorderRadius.circular(10.r),
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
              height: 1,
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
          SizedBox(height: 7.55.h),
          Text(
            "${item['count']}家",
            style: TextStyle(
              color: item['borderColor'],
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              height: 1.2,
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
    return GestureDetector(
      onTap: () => _handleMenuItemClick(item['title']),
      child: Container(
        width: MediaQuery.of(Get.context!).size.width / 2 - 24.w,
        padding: EdgeInsets.only(bottom: 10.w,top: 10.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: item['bgColor']),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(item['image'], width: 40.w, height: 40.w),
            SizedBox(height: 8.h),
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

  // 处理菜单项点击
  void _handleMenuItemClick(String title) {
    switch (title) {
      case '舆情热点':
        logic.goHotPot();
        break;
      case 'AI问答':
        logic.goAiQus();
        break;
      case '我的订阅':
        logic.goOrder();
        break;
      case '安全设置':
        logic.goSetting();
        break;
      default:
        break;
    }
  }

  // 清单更新信息
  Widget _buildListUpdate() {
    return GestureDetector(
      onTap: () => logic.goDetailList(),
      child: Container(
        padding: EdgeInsets.only(top: 17.h, left: 16.w, bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          children: [
            Image.asset(FYImages.detailList, width: 44.w, height: 44.h, fit: BoxFit.contain),
            SizedBox(width: 15.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "实体清单",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF222222),
                    height: 0.8,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
                SizedBox(height: 14.h),
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
      ),
    );
  }
}
