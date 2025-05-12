import 'package:get/get.dart';
import 'package:safe_app/routers/routers.dart';

import 'home_state.dart';

class HomeLogic extends GetxController {
  final HomeState state = HomeState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  // 去风险预警页
  void goRisk(){
    Get.toNamed(Routers.risk);
  }

  // 去热点页
  goHotPot() {
    Get.toNamed(Routers.hotPot);
  }
}
