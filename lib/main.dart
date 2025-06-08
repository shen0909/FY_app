import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/utils/pattern_lock_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 检查并确保锁屏方式不会冲突
  await _checkLockMethodConflicts();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

// 检查并解决锁屏方式冲突
Future<void> _checkLockMethodConflicts() async {
  try {
    bool isPatternEnabled = await PatternLockUtil.isPatternEnabled();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFingerprintEnabled = prefs.getBool('fingerprint_enabled') ?? false;
    
    // 如果两种锁屏方式都启用了，保留指纹解锁，禁用划线解锁
    if (isPatternEnabled && isFingerprintEnabled) {
      await PatternLockUtil.enablePatternLock(false);
      print('检测到锁屏方式冲突，已自动禁用划线解锁');
    }
  } catch (e) {
    print('检查锁屏方式时发生错误: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: false,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          getPages: Routers.pages,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'AlibabaPuHuiTi',
            appBarTheme: const AppBarTheme(
              surfaceTintColor: Colors.transparent,
            )
          ),
          initialRoute: Routers.login,
        );
      }
    );
  }
}

