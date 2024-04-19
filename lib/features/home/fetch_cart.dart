import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/app/const.dart';

Widget fetchCart() {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection("users-cart-items")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("items")
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return const Center(
          child: Text("Something is wrong"),
        );
      }
      if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
        return const Center(
          child: Text('Корзина пуста'),
        );
      }
      return ListView.builder(
          itemCount: snapshot.data == null ? 0 : snapshot.data!.docs.length,
          itemBuilder: (_, index) {
            DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];
            return ListTile(
              title: Text(documentSnapshot['name']),
              subtitle: Text(
                "${documentSnapshot['price']} x ${documentSnapshot['quantity']} = ${documentSnapshot['price'] * documentSnapshot['quantity']} руб.",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: primaryColor),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    child: const CircleAvatar(
                      backgroundColor: primaryColor,
                      child: Icon(Icons.remove),
                    ),
                    onTap: () {
                      FirebaseFirestore.instance
                          .collection("users-cart-items")
                          .doc(FirebaseAuth.instance.currentUser!.email)
                          .collection("items")
                          .doc(documentSnapshot.id)
                          .update({
                        "quantity": documentSnapshot['quantity'] -
                            (documentSnapshot['quantity'] == 1 ? 0 : 1),
                      });
                    },
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    child: const CircleAvatar(
                      backgroundColor: primaryColor,
                      child: Icon(Icons.delete),
                    ),
                    onTap: () {
                      FirebaseFirestore.instance
                          .collection("users-cart-items")
                          .doc(FirebaseAuth.instance.currentUser!.email)
                          .collection("items")
                          .doc(documentSnapshot.id)
                          .delete();
                    },
                  )
                ],
              ),
            );
          });
    },
  );
}
