import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/const.dart';
import 'package:mobile/features/purchase/thankyou_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PurchaseProcessingScreen extends StatefulWidget {
  const PurchaseProcessingScreen({super.key});

  @override
  PurchaseProcessingScreenState createState() =>
      PurchaseProcessingScreenState();
}

class PurchaseProcessingScreenState extends State<PurchaseProcessingScreen> {
  @override
  void initState() {
    Timer(
        const Duration(seconds: 1),
        () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const ThankyouScreen())));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Ожидание ответа от банка...",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 44.sp),
              ),
              SizedBox(
                height: 20.h,
              ),
              const CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
