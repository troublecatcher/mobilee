import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/const.dart';
import 'package:mobile/app/main.dart';
import 'package:mobile/common/custom_textfield.dart';
import 'package:mobile/features/navbar/bottom_nav_controller.dart';
import 'package:mobile/features/auth/registration_screen.dart';
import 'package:mobile/common/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  final _loginFormKey = GlobalKey<FormState>();

  signIn() async {
    if (_loginFormKey.currentState!.validate()) {
      try {
        UserCredential fb = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);
        var user = fb.user;
        if (user!.uid.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const BottomNavController(),
            ),
          );
        } else {
          Fluttertoast.showToast(msg: "Что-то пошло не так");
        }
      } on FirebaseAuthException catch (_) {
        Fluttertoast.showToast(msg: "Неверный email или пароль");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 150.h,
              width: ScreenUtil().screenWidth,
              child: Padding(
                padding: EdgeInsets.only(left: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Вход",
                      style: TextStyle(fontSize: 22.sp, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Form(
              key: _loginFormKey,
              child: Expanded(
                child: Container(
                  width: ScreenUtil().screenWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28.r),
                      topRight: Radius.circular(28.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: SingleChildScrollView(
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20.h,
                              ),
                              Text(
                                "Добро пожаловать!",
                                style: TextStyle(
                                    fontSize: 22.sp, color: primaryColor),
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              CustomTextField(
                                hintText: 'Email',
                                controller: _emailController,
                                keyboardType: TextInputType.text,
                                prefixIcon: Icons.email_outlined,
                                validationCallback: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Необходимо ввести email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              CustomTextField(
                                hintText: 'Пароль',
                                obscureText: _obscureText,
                                controller: _passwordController,
                                keyboardType: TextInputType.text,
                                prefixIcon: Icons.password,
                                suffixIcon: _obscureText == true
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscureText = false;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.remove_red_eye,
                                          size: 20.w,
                                        ))
                                    : IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscureText = true;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.visibility_off,
                                          size: 20.w,
                                        ),
                                      ),
                                validationCallback: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Необходимо ввести пароль';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 30.h,
                              ),
                              CustomButton(
                                buttonText: 'Войти',
                                onPressed: () => signIn(),
                              ),
                              SizedBox(height: 20.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Нет аккаунта? ",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFBBBBBB),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Text(
                                      "Зарегистрироваться",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const RegistrationScreen()));
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
