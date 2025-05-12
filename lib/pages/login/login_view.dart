import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_logic.dart';
import 'login_state.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final LoginLogic logic = Get.put(LoginLogic());
  final LoginState state = Get.find<LoginLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.headphones),
          Text('xxx App'),
          Text('请登录'),
          TextField(
            controller: state.nameController,
            decoration: InputDecoration(
              hintText: '用户名',
              labelText: '用户名',
              prefixIcon: Icon(Icons.account_circle),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              )
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: state.pwdController,
            decoration: InputDecoration(
              hintText: '用户名',
              labelText: '请输入密码',
              prefixIcon: Icon(Icons.account_circle),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              )
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => logic.submit(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.red,Colors.white]),
                borderRadius: BorderRadius.all(Radius.circular(12))
              ),
              child: Center(child: Text('登录',style: TextStyle(fontSize: 15),)),
            ),
          )
        ],
      ),
    );
  }
}
