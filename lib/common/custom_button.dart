import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/app/const.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final Function() onPressed;
  const CustomButton(
      {super.key, required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      height: 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          elevation: 3,
        ),
        child: Text(
          buttonText,
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
      ),
    );
  }
}
