import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_app/pages/settings/update_page.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/utils/pattern_lock_util.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/userDeviceInfo.dart';
import 'services/realm_service.dart';

late UserDeviceInfo userDeviceInfo;
bool isPad = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化SharedPreferences
  await FYSharedPreferenceUtils.initSP();
  
  // 初始化Realm数据库
  try {
    await RealmService().initialize();
    print('✅ Realm数据库初始化成功');
  } catch (e) {
    print('❌ Realm数据库初始化失败: $e');
  }
  
  // 检查并确保锁屏方式不会冲突
  await _checkLockMethodConflicts();
  String idiom = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).size.shortestSide >= 600
      ? 'pad'
      : 'phone';
  if (idiom == 'pad') {
    isPad = true;
  } else {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  FYSharedPreferenceUtils.saveUserDevice(idiom);
  userDeviceInfo = UserDeviceInfo(idiom: idiom);
  await ScreenUtil.ensureScreenSize();
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
      designSize: _getDesignSize(context),
      minTextAdapt: true,
      splitScreenMode: true,
      rebuildFactor: RebuildFactors.orientation,
      builder: (context, child) {
        return MediaQuery(
          // 固定文本缩放因子，避免受系统字体大小影响
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: GetMaterialApp(
            getPages: Routers.pages,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'AlibabaPuHuiTi',
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.black),
                titleTextStyle: TextStyle(
                  color: Colors.black, 
                  fontSize: 18.sp, 
                  fontWeight: FontWeight.bold
                ),
                centerTitle: true,
                surfaceTintColor: Colors.transparent,
              )
            ),
            initialRoute: Routers.login,
          ),
        );
      },
    );
  }
  
  // 动态计算设计尺寸的方法
  Size _getDesignSize(BuildContext context) {
    if (!isPad) {
      // 手机设备固定使用竖屏尺寸
      return const Size(375, 812);
    } else {
      // 平板设备根据当前屏幕方向动态选择
      final orientation = MediaQuery.of(context).orientation;
      final isLandscape = orientation == Orientation.landscape;
      
      print('🔄 屏幕方向变化: ${isLandscape ? "横屏" : "竖屏"}');
      
      if (isLandscape) {
        return const Size(960, 600); // 横屏尺寸
      } else {
        return const Size(600, 960); // 竖屏尺寸
      }
    }
  }
}

