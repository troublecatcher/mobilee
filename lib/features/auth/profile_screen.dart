import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/app/const.dart';
import 'package:mobile/app/main.dart';
import 'package:mobile/common/custom_textfield.dart';
import 'package:mobile/features/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  TextEditingController? _nameController;
  TextEditingController? _dobController;
  TextEditingController? _genderController;
  TextEditingController? _phoneController;
  List<ExpansionTile> expansionTiles = [];
  File? newImage;

  setDataToTextField(data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Builder(builder: (context) {
            if (newImage != null) {
              return GestureDetector(
                onTap: () => showCustomDialog(context),
                child: CircleAvatar(
                  maxRadius: 50.r,
                  minRadius: 50.r,
                  backgroundColor: primaryColor,
                  foregroundImage: FileImage(newImage!),
                ),
              );
            } else {
              return FutureBuilder(
                future: FirebaseStorage.instance
                    .ref('images')
                    .child('${FirebaseAuth.instance.currentUser!.email}.jpeg')
                    .getData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return GestureDetector(
                      onTap: () => showCustomDialog(context),
                      child: CircleAvatar(
                        maxRadius: 50.r,
                        minRadius: 50.r,
                        backgroundColor: primaryColor,
                        foregroundImage: MemoryImage(snapshot.data!),
                      ),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () => showCustomDialog(context),
                      child: CircleAvatar(
                        maxRadius: 50.r,
                        minRadius: 50.r,
                        backgroundColor: primaryColor,
                        child: newImage == null
                            ? const Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                ),
                              )
                            : null,
                      ),
                    );
                  }
                },
              );
            }
          }),
          const SizedBox(height: 15),
          TextField(
            enabled: false,
            controller: _nameController = TextEditingController(
              text: data['name'],
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            enabled: false,
            controller: _dobController = TextEditingController(
              text: data['dob'],
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today_outlined),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            enabled: false,
            controller: _genderController = TextEditingController(
              text: data['gender'],
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.accessibility),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _phoneController = TextEditingController(
              text: data['phone'],
            ),
            decoration: const InputDecoration(
              prefix: Text('+7 '),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () => updateData(),
                  child: const Text("Сохранить")),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ));
                },
                child: const Text("Выйти"),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Future<dynamic> showCustomDialog(BuildContext context) {
    return showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        content: FittedBox(
          child: Column(
            children: [
              IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final ImagePicker picker = ImagePicker();
                  final XFile? pickedImage =
                      await picker.pickImage(source: ImageSource.camera);
                  if (pickedImage != null) {
                    setState(() {
                      newImage = File(pickedImage.path);
                    });
                  }
                },
                icon: const Icon(Icons.camera_alt),
              ),
              IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final ImagePicker picker = ImagePicker();
                  final XFile? pickedImage =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    setState(() {
                      newImage = File(pickedImage.path);
                    });
                  }
                },
                icon: const Icon(Icons.photo),
              ),
            ],
          ),
        ),
      ),
    );
  }

  updateData() async {
    if (newImage != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('images')
          .child('${FirebaseAuth.instance.currentUser!.email}.jpeg');
      await ref
          .putFile(
              newImage!,
              SettableMetadata(
                contentType: "image/jpeg",
              ))
          .whenComplete(() async {
        CollectionReference collectionRef =
            FirebaseFirestore.instance.collection("users-form-data");
        await collectionRef
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          "phone": _phoneController!.text,
        }).then((value) => Fluttertoast.showToast(msg: "Успешно обновлено!"));
      });
    } else {
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection("users-form-data");
      await collectionRef.doc(FirebaseAuth.instance.currentUser!.email).update({
        "phone": _phoneController!.text,
      }).then((value) => Fluttertoast.showToast(msg: "Успешно обновлено!"));
    }
  }

  populateExpansionPanel(var order) {
    var container = [];
    num sum = 0;
    for (var orderItem in order.entries) {
      // print(orderItem['price']);
      sum += orderItem.value['subtotal'];
      container.add(ListTile(
        title: Text(orderItem.key, style: const TextStyle(color: Colors.black)),
        subtitle: Text(
            "${orderItem.value['price']} x ${orderItem.value['quantity']} = ${orderItem.value['subtotal']} руб.",
            style: const TextStyle(color: Colors.black)),
      ));
    }
    return ExpansionTile(
      title: Text('Заказ на сумму $sum руб.'),
      children: <Widget>[...container],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users-form-data")
                  .doc(FirebaseAuth.instance.currentUser!.email)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                var data = snapshot.data;
                if (data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return setDataToTextField(data);
              },
            ),
            const Center(
                child: Text(
              'Заказы',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: primaryColor,
              ),
            )),
            const SizedBox(
              height: 15,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .doc(FirebaseAuth.instance.currentUser!.email)
                  .collection('orders')
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && !snapshot.hasError) {
                  var orders =
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return data;
                  });
                  expansionTiles.length = 0;
                  for (var order in orders) {
                    expansionTiles.add(populateExpansionPanel(order));
                  }
                  return Column(
                    children: [...expansionTiles],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            )
          ],
        ),
      )),
    );
  }
}
