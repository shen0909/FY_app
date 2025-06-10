import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:safe_app/pages/detail_list/detail_list_view.dart';
import 'package:safe_app/pages/fingerprint_auth/fingerprint_auth_view.dart';
import 'package:safe_app/pages/home/home_view.dart';
import 'package:safe_app/pages/hot_pot/hot_details/hot_details_view.dart';
import 'package:safe_app/pages/hot_pot/hot_pot_view.dart';
import 'package:safe_app/pages/login/login_view.dart';
import 'package:safe_app/pages/risk/risk_details/risk_details_view.dart';
import 'package:safe_app/pages/risk/risk_view.dart';
import 'package:safe_app/pages/ai_qus/ai_qus_view.dart';
import 'package:safe_app/pages/order/order_view.dart';
import 'package:safe_app/pages/order/order_event_detial/order_event_detial_view.dart';
import 'package:safe_app/pages/setting/feed_back/feed_back_view.dart';
import 'package:safe_app/pages/setting/setting_view.dart';
import 'package:safe_app/pages/setting/use_tutorial/use_tutorial_view.dart';
import 'package:safe_app/pages/setting/user_login_data/user_login_data_view.dart';
import 'package:safe_app/pages/setting/privacy_safe/privacy_safe_view.dart';
import 'package:safe_app/pages/setting/pattern_setup/pattern_setup_view.dart';
import 'package:safe_app/pages/pattern_lock/pattern_lock_view.dart';
import 'package:safe_app/pages/setting/user_analysis/user_analysis_view.dart';
import '../pages/login/lock_method_selection/lock_method_selection_view.dart';
import '../pages/setting/permission_request/permission_request_view.dart';
import '../pages/setting/role_manager/role_manager_view.dart';

class Routers {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String risk = '/risk';
  static const String riskDetails = '/risk/details';
  static const String hotPot = '/hot/details';
  static const String aiQus = '/ai/qus';
  static const String order = '/order';
  static const String orderEventDetail = '/order_event_detail';
  static const String setting = '/setting';
  static const String roleManagement = '/role_management';
  static const String userAnalysis = '/user_analysis';
  static const String permissionRequests = '/permission_requests';
  static const String feedback = '/feedback';
  static const String hotDetails = '/hot_details';
  static const String userLoginData = '/user_login_data';
  static const String useTutorial = '/use_tutorial';
  static const String privacySafe = '/privacy_safe';
  static const String detailList = '/detail_list';
  static const String role_manager = '/role_manager';
  static const String permissionRequest = '/permission_request';
  static const String patternSetup = '/pattern_setup';
  static const String patternLock = '/pattern_lock';
  static const String lockMethodSelection = '/lock_method_selection';
  static const String fingerprintAuth = '/fingerprint_auth';

  static final List<GetPage> pages = [
    // GetPage(name: splash, page: () => SplashPage()),
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: risk, page: () => RiskPage()),
    GetPage(name: riskDetails, page: () => RiskDetailsPage()),
    GetPage(name: hotPot, page: () => HotPotPage()),
    GetPage(name: aiQus, page: () => AiQusPage()),
    GetPage(name: order, page: () => OrderPage()),
    GetPage(name: orderEventDetail, page: () => OrderEventDetialPage()),
    GetPage(name: setting, page: () => SettingPage()),
    GetPage(name: hotDetails, page: () => HotDetailsView()),
    GetPage(name: userLoginData, page: () => UserLoginDataPage()),
    GetPage(name: useTutorial, page: () => UseTutorialPage()),
    GetPage(name: privacySafe, page: () => PrivacySafePage()),
    GetPage(name: feedback, page: () => FeedBackPage()),
    GetPage(name: detailList, page: () => DetailListPage()),
    GetPage(name: role_manager, page: () => RoleManagerPage()),
    GetPage(name: permissionRequest, page: () => PermissionRequestPage()),
    GetPage(name: patternSetup, page: () => PatternSetupPage()),
    GetPage(name: patternLock, page: () => PatternLockPage()),
    GetPage(name: lockMethodSelection, page: () => LockMethodSelectionPage()),
    GetPage(name: fingerprintAuth, page: () => FingerprintAuthPage()),
    GetPage(name: userAnalysis, page: () => UserAnalysisPage()),
  ];
}