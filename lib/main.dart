import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/pages/login/login_view.dart';
import 'package:safe_app/routers/routers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: Routers.pages,
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

