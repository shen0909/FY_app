import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'order_event_detial_logic.dart';
import 'order_event_detial_state.dart';

class OrderEventDetialPage extends StatelessWidget {
  OrderEventDetialPage({Key? key}) : super(key: key);

  final OrderEventDetialLogic logic = Get.put(OrderEventDetialLogic());
  final OrderEventDetialState state = Get.find<OrderEventDetialLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
