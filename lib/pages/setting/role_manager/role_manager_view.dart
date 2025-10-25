import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';
import 'package:safe_app/widgets/widgets.dart';

import 'role_manager_logic.dart';
import 'role_manager_state.dart';

// 添加用户弹窗
class AddUserDialog extends StatefulWidget {
  const AddUserDialog({Key? key}) : super(key: key);

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  late final RoleManagerLogic logic;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  String selectedRole = '普通用户';
  int selectedRoleIndex = 0; // 0 普通用户 1 管理员 2 审核员

  @override
  void initState() {
    super.initState();
    logic = Get.find<RoleManagerLogic>();
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 弹窗内容
          Container(
            width: Get.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题栏
                Container(
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: FYColors.color_F9F9F9),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '新增用户',
                        style: TextStyle(
                          color: FYColors.color_1A1A1A,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: FYColors.color_1A1A1A),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),
                // 表单
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      // 用户名
                      _buildInputField(
                        label: '用户名',
                        controller: nameController,
                        hintText: '请输入',
                      ),
                      SizedBox(height: 16.h),

                      // 角色选择
                      _buildRoleSelector(),
                      SizedBox(height: 16.h),

                      // 初始密码
                      _buildInputField(
                        label: '初始密码',
                        controller: passwordController,
                        hintText: '请输入',
                        obscureText: true,
                      ),
                      SizedBox(height: 16.h),

                      // 备注
                      _buildInputField(
                        label: '备注',
                        controller: remarkController,
                        hintText: '请输入',
                        maxLines: 3,
                      ),
                      SizedBox(height: 16.h),

                      // 提示信息
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: FYColors.color_A6A6A6,
                            size: 20.w,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '添加管理员或审核员需要经过现有审核员的审核',
                              style: TextStyle(
                                color: FYColors.color_A6A6A6,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 底部按钮
                // const Spacer(),
                Container(
                  height: 72.h,
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: FYColors.color_F9F9F9),
                    ),
                  ),
                  child: Row(
                    children: [
                      // 取消按钮
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: FYColors.color_F9F9F9,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '取消',
                              style: TextStyle(
                                color: FYColors.color_1A1A1A,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // 提交审核按钮
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            logic.addUser(
                              nameController.text,
                              selectedRoleIndex,
                              passwordController.text,
                              remarkController.text,
                            );
                          },
                          child: Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: FYColors.loginBtn,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '提交审核',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return Container(
      height: maxLines > 1 ? 72.h : 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: FYColors.color_F9F9F9,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: FYColors.color_666666,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: FYColors.color_A6A6A6,
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return GestureDetector(
      onTap: _showRoleSelector,
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: FYColors.color_F9F9F9,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Text(
              '角色',
              style: TextStyle(
                color: FYColors.color_666666,
                fontSize: 14.sp,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    selectedRole,
                    style: TextStyle(
                      color: FYColors.color_1A1A1A,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: FYColors.color_1A1A1A,
                    size: 16.w,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleSelector() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('管理员', textAlign: TextAlign.center),
                onTap: () {
                  setState(() {
                    selectedRole = '管理员';
                    selectedRoleIndex = 1;
                  });
                  Get.back();
                },
              ),
              Divider(height: 0),
              ListTile(
                title: Text('审核员', textAlign: TextAlign.center),
                onTap: () {
                  setState(() {
                    selectedRole = '审核员';
                    selectedRoleIndex = 2;
                  });
                  Get.back();
                },
              ),
              Divider(height: 0),
              ListTile(
                title: Text('普通用户', textAlign: TextAlign.center),
                onTap: () {
                  setState(() {
                    selectedRole = '普通用户';
                    selectedRoleIndex = 3;
                  });
                  Get.back();
                },
              ),
              Container(
                width: double.infinity,
                color: FYColors.color_F5F5F5,
                height: 8.h,
              ),
              ListTile(
                title: Text('取消', textAlign: TextAlign.center),
                onTap: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleManagerPage extends StatelessWidget {
  RoleManagerPage({Key? key}) : super(key: key);

  final RoleManagerLogic logic = Get.put(RoleManagerLogic());
  final RoleManagerState state = Get
      .find<RoleManagerLogic>()
      .state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FYAppBar(
        title: '角色管理',
        actions: [
          InkWell(
            onTap: logic.showAddUserDialog,
            child: Row(
              children: [
                Icon(Icons.add, color: FYColors.color_1A1A1A, size: 24.w),
                SizedBox(width: 4.w),
                Text(
                  '添加',
                  style: TextStyle(
                      color: FYColors.color_1A1A1A,
                      fontSize: 14.sp
                  ),
                ),
                SizedBox(width: 16.w),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: 16.w, right: 16.w, top: 16.h, bottom: 16.h),
                child: Row(
                  children: [
                    Text(
                      '用户权限管理',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Container(
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: FYColors.color_E6E6E6),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 16.w),
                            Icon(
                                Icons.search,
                                color: FYColors.color_3A3A3A,
                                size: 20.w
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: TextField(
                                controller: logic.searchController,
                                onChanged: logic.searchUser,
                                decoration: InputDecoration(
                                  hintText: '搜索用户名称',
                                  hintStyle: TextStyle(
                                      color: FYColors.color_A6A6A6,
                                      fontSize: 14.sp
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8.h),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              state.filteredUserList.length == 0 || state.filteredUserList.isEmpty
                  ? FYWidget.buildEmptyContent()
                  : Expanded(
                child: Row(
                  children: [
                    // 固定的首列
                    Expanded(
                      flex: 2,
                      // width: 80.w,
                      child: Column(
                        children: [
                          // 首列表头
                          Container(
                            height: 28.h,
                            color: FYColors.color_F0F5FF,
                            padding: EdgeInsets.only(left: 16.w),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '用户名',
                              style: TextStyle(
                                color: FYColors.color_3361FE,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          // 首列数据
                          Expanded(
                            child: Obx(() =>
                                ListView.builder(
                                  controller: logic.leftVerticalController,
                                  itemCount: state.filteredUserList.length,
                                  itemBuilder: (context, index) {
                                    final user =
                                    state.filteredUserList[index];
                                    return Container(
                                      height: 44.h,
                                      width: 40.w,
                                      decoration: BoxDecoration(
                                        color: index % 2 == 0
                                            ? Colors.white
                                            : FYColors.color_F9F9F9,
                                        border: const Border(
                                          bottom: BorderSide(
                                              color: FYColors.color_F9F9F9),
                                        ),
                                      ),
                                      padding: EdgeInsets.only(left: 16.w),
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        children: [
                                          Text(
                                            '${user.nickname}',
                                            style: TextStyle(
                                              color: FYColors.color_1A1A1A,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '(${user.username})',
                                            style: TextStyle(
                                              color: FYColors.color_1A1A1A,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )),
                          )
                        ],
                      ),
                    ),
                    // 右侧可滚动部分
                    Expanded(
                      flex: 6,
                      child: Stack(
                        children: [
                          // 滚动内容
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: logic.horizontalScrollController,
                            child: SizedBox(
                              width: MediaQuery
                                  .of(Get.context!)
                                  .size
                                  .width, // 设置足够的宽度让内容可以滚动
                              child: Column(
                                children: [
                                  // 表头行
                                  Container(
                                    height: 28.h,
                                    color: FYColors.color_F0F5FF,
                                    child: Row(
                                      children: [
                                        _buildTableHeader('角色', flex: 1),
                                        _buildTableHeader('状态', flex: 1),
                                        _buildTableHeader(
                                            '最后登录时间', flex: 2),
                                        _buildTableHeader('操作', flex: 1),
                                      ],
                                    ),
                                  ),

                                  // 表格数据行
                                  Expanded(
                                    child: Obx(() =>
                                        ListView.builder(
                                          controller:
                                          logic.rightVerticalController,
                                          itemCount:
                                          state.filteredUserList.length,
                                          itemBuilder: (context, index) {
                                            final user =
                                            state.filteredUserList[index];
                                            return Container(
                                              height: 44.h,
                                              decoration: BoxDecoration(
                                                color: index % 2 == 0
                                                    ? Colors.white
                                                    : FYColors.color_F9F9F9,
                                                border: Border(
                                                  bottom: BorderSide(
                                                      color: FYColors
                                                          .color_F9F9F9),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: _buildRoleBadge(
                                                        user.role!),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: _buildStatusBadge(
                                                        user.status),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      DateFormat(
                                                          'yyyy-MM-dd HH:mm')
                                                          .format(DateTime
                                                          .parse(user
                                                          .createdAt!)),
                                                      textAlign:
                                                      TextAlign.center,
                                                      style: TextStyle(
                                                        color: FYColors
                                                            .color_1A1A1A,
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                        FontWeight.w400,
                                                      ),
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: IconButton(
                                                      icon: Icon(Icons.edit,
                                                          color: FYColors
                                                              .color_3361FE,
                                                          size: 16.w),
                                                      onPressed: () =>
                                                          logic
                                                              .editUser(user),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 右侧滑动指示阴影
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Obx(() {
                              // 当没有数据时不显示指示器
                              if (state.filteredUserList.isEmpty) {
                                return SizedBox();
                              }
                              return Container(
                                width: 16.w,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildLoadMoreIndicator()
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (state.isLoadingMore.value) {
        // 正在加载更多
        return Container(
          padding: EdgeInsets.all(16.w),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8.w),
              Text(
                '加载中...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: FYColors.color_999999,
                ),
              ),
            ],
          ),
        );
      } else if (!state.hasMoreData.value && state.filteredUserList.isNotEmpty) {
        // 没有更多数据（但有数据时才显示）
        return Container(
          padding: EdgeInsets.all(16.w),
          alignment: Alignment.center,
          child: Text(
            '已显示全部 ${state.filteredUserList.length} 条数据',
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_999999,
            ),
          ),
        );
      } else if (state.hasMoreData.value && state.filteredUserList.isNotEmpty) {
        // 还有更多数据但当前未加载
        return Container(
          padding: EdgeInsets.all(16.w),
          alignment: Alignment.center,
          child: Text(
            '上拉加载更多',
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_999999,
            ),
          ),
        );
      } else {
        // 其他情况
        return SizedBox(height: 20.h);
      }
    });
  }

  Widget _buildTableHeader(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: FYColors.color_3361FE,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildRoleBadge(int role) {
    Color bgColor;
    Color textColor;
    String roleText;
    switch (role) {
      case 0:
        roleText = '普通用户';
        bgColor = const Color(0xFFFFF7E9);
        textColor = const Color(0xFFFF9719);
        break;
      case 1:
        roleText = '管理员';
        bgColor = const Color(0xFFE7FEF8);
        textColor = const Color(0xFF07CC89);
        break;
      case 2:
      default:
        roleText = '审核员';
        bgColor = const Color(0xFFEDEDED);
        textColor = FYColors.color_1A1A1A;
        break;
    }

    return Container(
      margin: EdgeInsets.only(top: 10.h, bottom: 10.h, right: 12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      alignment: Alignment.center,
      child: Text(
        roleText,
        style: TextStyle(
          color: textColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case '在线':
        bgColor = const Color(0xFFE7FEF8);
        textColor = const Color(0xFF07CC89);
        break;
      case '申请中':
        bgColor = const Color(0xFFFFF7E9);
        textColor = const Color(0xFFFF9719);
        break;
      case '离线':
      default:
        bgColor = const Color(0xFFEDEDED);
        textColor = FYColors.color_1A1A1A;
        break;
    }

    return Container(
      margin: EdgeInsets.only(top: 10.h, bottom: 10.h,),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      alignment: Alignment.center,
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
