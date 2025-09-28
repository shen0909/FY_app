import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/utils/pattern_lock_util.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cache/cache_initializer.dart';
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
  // 改进的设备类型检测逻辑
  String idiom = await _detectDeviceTypeReliably();

  if (idiom == 'pad') {
    isPad = true;
    print('✅ 设备确认为平板，启用平板适配模式');
  } else {
    isPad = false;
    print('✅ 设备确认为手机，启用手机适配模式并锁定竖屏');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  FYSharedPreferenceUtils.saveUserDevice(idiom);
  userDeviceInfo = UserDeviceInfo(idiom: idiom);
  await ScreenUtil.ensureScreenSize();
  await _initializeCacheService();
  runApp(const MyApp());
}

/// 确保缓存服务可用
Future<void> _initializeCacheService() async {
  try {
    // 尝试确保缓存系统初始化（幂等操作）
    await CacheInitializer.initialize();
    if (kDebugMode) {
      print('✅ 缓存系统初始化成功');
      print('📊 缓存调试信息: ${CacheInitializer.getDebugInfo()}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ 确保缓存服务可用失败: $e');
    }
  }
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

// 可靠的设备类型检测函数
Future<String> _detectDeviceTypeReliably() async {
  try {
    // 1. 首先尝试从缓存获取设备类型
    String? cachedDeviceType = await FYSharedPreferenceUtils.getUserDevice();

    // 2. 获取当前屏幕尺寸
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = MediaQueryData.fromView(view).size;
    final shortestSide = size.shortestSide;
    final longestSide = size.longestSide;

    print('📱 设备屏幕尺寸检测: ${size.width}x${size.height}, 最短边: $shortestSide, 最长边: $longestSide');

    // 3. 如果获取到的尺寸为0，说明还未初始化完成
    if (shortestSide == 0.0 || longestSide == 0.0) {
      print('⚠️ 屏幕尺寸未初始化(0x0)，使用缓存设备类型或等待初始化');

      if (cachedDeviceType != null && cachedDeviceType.isNotEmpty) {
        print('📱 使用缓存的设备类型: $cachedDeviceType');
        return cachedDeviceType;
      }

      // 如果没有缓存，等待一小段时间再次尝试
      print('🔄 等待屏幕初始化...');
      await Future.delayed(Duration(milliseconds: 100));

      // 再次尝试获取屏幕尺寸
      final retryView = WidgetsBinding.instance.platformDispatcher.views.first;
      final retrySize = MediaQueryData.fromView(retryView).size;
      final retryShortestSide = retrySize.shortestSide;

      print('📱 重试后屏幕尺寸: ${retrySize.width}x${retrySize.height}, 最短边: $retryShortestSide');

      if (retryShortestSide > 0) {
        String detectedType = retryShortestSide >= 600 ? 'pad' : 'phone';
        print('📱 重试后设备类型判定: $detectedType');
        return detectedType;
      }

      // 如果还是获取不到，默认返回手机类型（更安全）
      print('❌ 无法获取屏幕尺寸，默认为手机设备');
      return 'phone';
    }

    // 4. 正常情况下的设备类型判定
    String detectedType = shortestSide >= 600 ? 'pad' : 'phone';
    print('📱 设备类型判定: $detectedType');

    // 5. 如果缓存类型与检测类型不一致，更新缓存
    if (cachedDeviceType != null && cachedDeviceType != detectedType) {
      print('🔄 设备类型变化: $cachedDeviceType -> $detectedType，更新缓存');
    }

    return detectedType;

  } catch (e) {
    print('❌ 设备类型检测失败: $e，默认为手机设备');
    return 'phone';
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
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', ''), // 简体中文（不带国家代码）
              Locale('zh', 'CN'), // 简体中文（中国大陆）
              Locale('zh', 'TW'), // 繁体中文（台湾）
            ],
            initialRoute: Routers.login,
          ),
        );
      },
    );
  }
  
  // 动态计算设计尺寸的方法
  Size _getDesignSize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final actualSize = mediaQuery.size;

    if (!isPad) {
      // 手机设备固定使用竖屏尺寸
      final designSize = const Size(375, 812);
      print('📱 手机设计尺寸: $designSize, 实际屏幕尺寸: $actualSize');
      return designSize;
    } else {
      // 平板设备根据当前屏幕方向动态选择
      final orientation = mediaQuery.orientation;
      final isLandscape = orientation == Orientation.landscape;

      Size designSize;
      if (isLandscape) {
        designSize = const Size(960, 600); // 横屏尺寸
      } else {
        designSize = const Size(600, 960); // 竖屏尺寸
      }
      print('📱 平板设计尺寸: $designSize (${isLandscape ? "横屏" : "竖屏"}), 实际屏幕尺寸: $actualSize');
      return designSize;
    }
  }
}

