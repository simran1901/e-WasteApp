import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 3,
          width: MediaQuery.of(context).size.width * 4 / 5,
          child: Image.asset(
            'assets/images/shopping.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
