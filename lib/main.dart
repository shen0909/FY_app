import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_app/routers/routers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          getPages: Routers.pages,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'AlibabaPuHuiTi',
          ),
          initialRoute: Routers.login,
        );
      }
    );
  }
}

