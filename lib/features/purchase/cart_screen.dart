import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/const.dart';
import 'package:mobile/features/purchase/purchase_processing.dart';
import 'package:mobile/features/home/fetch_cart.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: fetchCart(),
      ),
      floatingActionButton: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users-cart-items")
              .doc(FirebaseAuth.instance.currentUser!.email)
              .collection("items")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return ElevatedButton(
                onPressed: () => {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PurchaseProcessingScreen()))
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 10,
                ),
                child: const Text(
                  "Купить",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
    );
  }
}
