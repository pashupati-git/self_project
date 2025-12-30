import 'package:flutter/material.dart';
import 'package:login/screens/login.dart';
import 'package:login/screens/signup.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,

      child: Scaffold(
        appBar: AppBar(
          title: Text("Home"),
          bottom: TabBar(tabs: [Tab(text: "Login"),Tab(text: "Sign up")],),

        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TabBarView(
            children: [
              Login(),
              Signup(),
            ],
          ),
        ),

      ),
    );
  }
}
