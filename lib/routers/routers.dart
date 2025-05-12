import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:safe_app/pages/home/home_view.dart';
import 'package:safe_app/pages/login/login_view.dart';
import 'package:safe_app/pages/risk/risk_view.dart';

class Routers {
  static const String login = '/login';
  static const String home = '/home';
  static const String risk = '/risk';

  static final List<GetPage> pages = [
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: risk, page: () => RiskPage()),
  ];
}