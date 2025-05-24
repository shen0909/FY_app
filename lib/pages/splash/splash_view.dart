import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'splash_logic.dart';

class SplashPage extends StatelessWidget {
  SplashPage({Key? key}) : super(key: key);

  final logic = Get.put(SplashLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 应用Logo
            Image.asset(
              'assets/images/app_logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            // 加载指示器
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
} 