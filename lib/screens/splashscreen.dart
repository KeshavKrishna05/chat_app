import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chat'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
