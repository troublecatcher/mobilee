import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/const.dart';
import 'package:mobile/features/navbar/bottom_nav_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThankyouScreen extends StatefulWidget {
  const ThankyouScreen({super.key});

  @override
  ThankyouScreenState createState() => ThankyouScreenState();
}

class ThankyouScreenState extends State<ThankyouScreen> {
  var cart = [];
  getCart() async {
    QuerySnapshot qn = await FirebaseFirestore.instance
        .collection("users-cart-items")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("items")
        .get();
    setState(() {
      for (int i = 0; i < qn.docs.length; i++) {
        cart.add({
          "name": qn.docs[i]["name"],
          "quantity": qn.docs[i]["quantity"],
          "price": qn.docs[i]["price"]
        });
      }
    });
    return qn.docs;
  }

  confirmOrder() async {
    await getCart();

    num sum = 0;
    for (var element in cart) {
      sum += element["quantity"] * element["price"];
    }
    for (var element in cart) {
      FirebaseFirestore.instance
          .collection("orders")
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('orders')
          .doc(sum.toString())
          .set({
        '${element['name']}': {
          'price': element['price'],
          'quantity': element['quantity'],
          'subtotal': element['price'] * element['quantity'],
        },
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection("users-cart-items")
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection("items")
          .doc(element["name"])
          .delete();
    }
    sum = 0;
  }

  @override
  void initState() {
    super.initState();
    confirmOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Спасибо за покупку!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 44.sp),
                    ),
                    ElevatedButton(
                      child: Text(
                        "Продолжить шоппинг",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 20.sp),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const BottomNavController()));
                      },
                    )
                  ],
                ),
              ))),
    );
  }
}
