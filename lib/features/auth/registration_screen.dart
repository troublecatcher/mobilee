import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/const.dart';
import 'package:mobile/common/custom_textfield.dart';
import 'package:mobile/features/auth/login_screen.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/features/navbar/bottom_nav_controller.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  bool _obscureText = true;

  DateTime? dob;
  List<String> gender = ["Пол не указан", "Мужской", "Женский"];
  File? newImage;

  final _registrationFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _genderController.text = gender.first;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> _selectDateFromPicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year),
      firstDate: DateTime(DateTime.now().year - 150),
      lastDate: DateTime(DateTime.now().year),
    );
    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat('dd.MM.yyyy').format(pickedDate);
        dob = pickedDate;
      });
    }
  }

  Future<void> signUp() async {
    if (_registrationFormKey.currentState!.validate()) {
      if (_passwordController.text != _passwordConfirmationController.text) {
        Fluttertoast.showToast(msg: "Пароли не совпадают");
      }
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);
        var user = userCredential.user;
        if (user!.uid.isNotEmpty) {
          CollectionReference collectionRef =
              FirebaseFirestore.instance.collection("users-form-data");
          collectionRef.doc(user.email).set({
            "name": _nameController.text,
            "phone": _phoneController.text,
            "dob": _dobController.text,
            "gender": _genderController.text,
          }).then(
            (value) async {
              if (newImage != null) {
                final ref = FirebaseStorage.instance
                    .ref()
                    .child('images')
                    .child('${user.email}.jpeg');
                await ref
                    .putFile(
                        newImage!,
                        SettableMetadata(
                          contentType: "image/jpeg",
                        ))
                    .whenComplete(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BottomNavController(),
                    ),
                  );
                });
              }
            },
          );
        } else {
          Fluttertoast.showToast(msg: "Что-то пошло не так");
        }
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'email-already-in-use':
            Fluttertoast.showToast(msg: "Такой email уже используется");
            break;
          case 'invalid-email':
            Fluttertoast.showToast(msg: "Неправильный формат email");
            break;
          case 'weak-password':
            Fluttertoast.showToast(msg: "Слишком слабый пароль");
            break;
          default:
            Fluttertoast.showToast(msg: "Что-то пошло не так");
        }
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
                      "Регистрация",
                      style: TextStyle(fontSize: 22.sp, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Form(
              key: _registrationFormKey,
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
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20.h,
                          ),
                          Text(
                            "Давайте знакомиться",
                            style:
                                TextStyle(fontSize: 22.sp, color: primaryColor),
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
                          CustomTextField(
                            obscureText: _obscureText,
                            hintText: 'Пароль',
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
                          CustomTextField(
                            obscureText: _obscureText,
                            hintText: 'Подтверждение пароля',
                            controller: _passwordConfirmationController,
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
                                return 'Необходимо подтвердить пароль';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              Expanded(
                                flex: 7,
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      hintText: 'Имя',
                                      controller: _nameController,
                                      keyboardType: TextInputType.text,
                                      prefixIcon: Icons.person,
                                      validationCallback: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Необходимо ввести имя';
                                        }
                                        return null;
                                      },
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: TextFormField(
                                        readOnly: true,
                                        onTap: () =>
                                            _selectDateFromPicker(context),
                                        controller: _dobController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "Дата рождения",
                                          prefixIcon: Icon(
                                            Icons.calendar_today_outlined,
                                            color: primaryColor,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Необходимо указать дату рождения';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                flex: 3,
                                child: GestureDetector(
                                  onTap: () => showAdaptiveDialog(
                                    context: context,
                                    builder: (context) => AlertDialog.adaptive(
                                      content: FittedBox(
                                        child: Column(
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                final ImagePicker picker =
                                                    ImagePicker();
                                                final XFile? pickedImage =
                                                    await picker.pickImage(
                                                        source:
                                                            ImageSource.camera);
                                                if (pickedImage != null) {
                                                  setState(() {
                                                    newImage =
                                                        File(pickedImage.path);
                                                  });
                                                }
                                              },
                                              icon:
                                                  const Icon(Icons.camera_alt),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                final ImagePicker picker =
                                                    ImagePicker();
                                                final XFile? pickedImage =
                                                    await picker.pickImage(
                                                        source: ImageSource
                                                            .gallery);
                                                if (pickedImage != null) {
                                                  setState(() {
                                                    newImage =
                                                        File(pickedImage.path);
                                                  });
                                                }
                                              },
                                              icon: const Icon(Icons.photo),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    maxRadius: 50.r,
                                    minRadius: 50.r,
                                    backgroundColor: primaryColor,
                                    foregroundImage: newImage != null
                                        ? FileImage(newImage!)
                                        : null,
                                    child: newImage == null
                                        ? const Align(
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.add_a_photo_outlined,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          CustomTextField(
                            hintText: 'Телефон',
                            controller: _phoneController,
                            keyboardType: TextInputType.number,
                            prefix: const Text('+7 '),
                            prefixIcon: Icons.phone,
                            validationCallback: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Необходимо ввести телефон';
                              }
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(4.r)),
                                    child: DropdownButton<String>(
                                      underline: const SizedBox.shrink(),
                                      isExpanded: true,
                                      alignment: Alignment.centerRight,
                                      value: _genderController.text,
                                      items: gender.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                          onTap: () {
                                            setState(() {
                                              _genderController.text = value;
                                            });
                                          },
                                        );
                                      }).toList(),
                                      onChanged: (_) {},
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 1.sw,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: () {
                                signUp();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                elevation: 3,
                              ),
                              child: Text(
                                "Создать аккаунт",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18.sp),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Уже есть аккаунт?",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFBBBBBB),
                                ),
                              ),
                              GestureDetector(
                                child: Text(
                                  " Войти",
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
                                              const LoginScreen()));
                                },
                              )
                            ],
                          ),
                          SizedBox(height: 30.h),
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
