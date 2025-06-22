import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';

import '../../../widgets/custom_app_bar.dart';
import 'update_page_logic.dart';
import 'update_page_state.dart';

class UpdatePagePage extends StatelessWidget {
  UpdatePagePage({Key? key}) : super(key: key);

  final UpdatePageLogic logic = Get.put(UpdatePageLogic());
  final UpdatePageState state = Get.find<UpdatePageLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FYAppBar(
        title: '版本更新',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: logic.checkUpdate,
            tooltip: '重新检查',
          ),
        ],
      ),
      body: GetBuilder<UpdatePageLogic>(
        builder: (controller) {
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.isLoading)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16.w),
                        Text('正在检查更新...'),
                      ],
                    ),
                  )
                else if (state.updateInfo != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '发现新版本: ${state.updateInfo!['version']}',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.w),
                                Text('当前版本: ${state.currentVersion ?? '未知'}',
                                    style: TextStyle(fontSize: 14.sp)),
                                SizedBox(height: 16.w),
                                Text(
                                  '更新内容:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp),
                                ),
                                SizedBox(height: 8.w),
                                Text(
                                    state.updateInfo!['description'] ??
                                        '暂无更新说明',
                                    style: TextStyle(fontSize: 14.sp)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.w),
                        if (state.isDownloading)
                          Column(
                            children: [
                              LinearProgressIndicator(
                                value: state.downloadProgress,
                                backgroundColor: Colors.grey[300],
                              ),
                              SizedBox(height: 8.w),
                              RepaintBoundary(
                                  child: Text(
                                      '下载进度: ${(state.downloadProgress * 100).toStringAsFixed(1)}%')),
                              SizedBox(height: 16.w),
                              ElevatedButton(
                                onPressed: logic.cancelDownloadIfNeeded,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0XFF345DFF),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.w, horizontal: 12.w),
                                ),
                                child: Text(
                                  '取消下载',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: FYColors.whiteColor),
                                ),
                              ),
                            ],
                          )
                        else if (state.isInstalling)
                          Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16.w),
                              Text('正在安装更新...'),
                            ],
                          )
                        else
                          ElevatedButton(
                            onPressed: logic.downloadUpdate,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.w),
                              backgroundColor: Color(0XFF345DFF),
                            ),
                            child: Text('下载并安装更新',
                                style: TextStyle(fontSize: 14.sp, color: FYColors.whiteColor)),
                          ),
                      ],
                    ),
                  )
                else
                  Center(
                    child: Text(
                      '当前已是最新版本',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),

                // if (state.errorMessage.isNotEmpty)
                //   Padding(
                //     padding: EdgeInsets.only(top: 16.w),
                //     child: Text(
                //       state.errorMessage,
                //       style: const TextStyle(color: Colors.red),
                //       textAlign: TextAlign.center,
                //     ),
                //   ),
              ],
            ),
          );
        },
      ),
    );
  }
}
