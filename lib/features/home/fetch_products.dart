import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/const.dart';

Widget fetchProducts(String collectionName) {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection(collectionName)
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("items")
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return const Center(
          child: Text("Something is wrong"),
        );
      }

      return ListView.builder(
          itemCount: snapshot.data == null ? 0 : snapshot.data!.docs.length,
          itemBuilder: (_, index) {
            DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];
            return ListTile(
              title: Text(documentSnapshot['name']),
              subtitle: Text(
                "${documentSnapshot['price']} руб.",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: primaryColor),
              ),
              trailing: GestureDetector(
                child: const CircleAvatar(
                  backgroundColor: primaryColor,
                  child: Icon(Icons.delete),
                ),
                onTap: () {
                  FirebaseFirestore.instance
                      .collection(collectionName)
                      .doc(FirebaseAuth.instance.currentUser!.email)
                      .collection("items")
                      .doc(documentSnapshot.id)
                      .delete();
                },
              ),
            );
          });
    },
  );
}
