import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'detail_list_logic.dart';
import 'detail_list_state.dart';

/// 清单信息
class DetailListPage extends StatelessWidget {
  DetailListPage({Key? key}) : super(key: key);

  final DetailListLogic logic = Get.put(DetailListLogic());
  final DetailListState state = Get.find<DetailListLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
