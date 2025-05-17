import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:safe_app/pages/home/home_view.dart';
import 'package:safe_app/pages/hot_pot/hot_details/hot_details_view.dart';
import 'package:safe_app/pages/hot_pot/hot_pot_view.dart';
import 'package:safe_app/pages/login/login_view.dart';
import 'package:safe_app/pages/risk/risk_details/risk_details_view.dart';
import 'package:safe_app/pages/risk/risk_view.dart';
import 'package:safe_app/pages/ai_qus/ai_qus_view.dart';
import 'package:safe_app/pages/order/order_view.dart';
import 'package:safe_app/pages/setting/setting_view.dart';

class Routers {
  static const String login = '/login';
  static const String home = '/home';
  static const String risk = '/risk';
  static const String riskDetails = '/risk/details';
  static const String hotPot = '/hot/details';
  static const String aiQus = '/ai/qus';
  static const String order = '/order';
  static const String setting = '/setting';
  static const String roleManagement = '/role_management';
  static const String userAnalysis = '/user_analysis';
  static const String permissionRequests = '/permission_requests';
  static const String feedback = '/feedback';
  static const String hotDetails = '/hot_details';

  static final List<GetPage> pages = [
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: risk, page: () => RiskPage()),
    GetPage(name: riskDetails, page: () => RiskDetailsPage()),
    GetPage(name: hotPot, page: () => HotPotPage()),
    GetPage(name: aiQus, page: () => AiQusPage()),
    GetPage(name: order, page: () => OrderPage()),
    GetPage(name: setting, page: () => SettingPage()),
    GetPage(name: hotDetails, page: () => HotDetailsView()),
  ];
}