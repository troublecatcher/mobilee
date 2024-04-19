import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/app/const.dart';
import 'package:mobile/features/home/product.dart';

class ProductDetails extends StatefulWidget {
  final Product product;
  const ProductDetails(this.product, {super.key});
  @override
  ProductDetailsState createState() => ProductDetailsState();
}

List cart = [];
final FirebaseAuth _auth = FirebaseAuth.instance;
var currentUser = _auth.currentUser;
var _firestoreInstance = FirebaseFirestore.instance;

class ProductDetailsState extends State<ProductDetails> {
  fetchCart() async {
    QuerySnapshot qn = await _firestoreInstance
        .collection("users-cart-items")
        .doc(currentUser!.email)
        .collection("items")
        .get();
    setState(() {
      cart.length = 0;
      for (int i = 0; i < qn.docs.length; i++) {
        cart.add(
            {"name": qn.docs[i]["name"], "quantity": qn.docs[i]["quantity"]});
      }
    });
    return qn.docs;
  }

  @override
  void initState() {
    fetchCart();
    super.initState();
  }

  Future addToCart() async {
    await fetchCart();
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection("users-cart-items");

    bool isInCart = false;
    int quantity = 0;
    for (var cartItem in cart) {
      if (cartItem["name"] == widget.product.name) {
        isInCart = true;
        quantity = cartItem["quantity"];
      }
    }
    String msg = "";
    if (isInCart == false) {
      quantity = 1;
      msg = "Добавлено в корзину!";
    } else {
      ++quantity;
      msg = "В корзине: $quantity";
    }
    collectionRef
        .doc(currentUser!.email)
        .collection("items")
        .doc(widget.product.name)
        .set({
      "quantity": quantity,
      "name": widget.product.name,
      "price": widget.product.price,
      "images": widget.product.images,
    }).then((value) => Fluttertoast.showToast(msg: msg));
  }

  Future addToFavourite() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    var currentUser = auth.currentUser;
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection("users-favourite-items");
    return collectionRef
        .doc(currentUser!.email)
        .collection("items")
        .doc(widget.product.name)
        .set({
      "name": widget.product.name,
      "price": widget.product.price,
      "images": widget.product.images,
    }).then((value) => Fluttertoast.showToast(msg: "Добавлено в избранное!"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: primaryColor,
            child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                )),
          ),
        ),
        actions: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users-favourite-items")
                .doc(FirebaseAuth.instance.currentUser!.email)
                .collection("items")
                .where("name", isEqualTo: widget.product.name)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return const Text("");
              }
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  backgroundColor: primaryColor,
                  child: IconButton(
                    onPressed: () => snapshot.data.docs.length == 0
                        ? addToFavourite()
                        : Fluttertoast.showToast(msg: "Уже добавлено"),
                    icon: snapshot.data.docs.length == 0
                        ? const Icon(
                            Icons.favorite_outline,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.favorite,
                            color: Colors.white,
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: CarouselSlider(
                  items: widget.product.images
                      .map<Widget>((item) => Padding(
                            padding: const EdgeInsets.only(left: 3, right: 3),
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                image: NetworkImage(item),
                              )),
                            ),
                          ))
                      .toList(),
                  options: CarouselOptions(
                      autoPlay: false,
                      autoPlayInterval: const Duration(seconds: 5),
                      enlargeCenterPage: true,
                      viewportFraction: 0.8,
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      onPageChanged: (val, carouselPageChangedReason) {
                        setState(() {});
                      })),
            ),
            Text(
              widget.product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            Text(widget.product.description),
            const SizedBox(
              height: 10,
            ),
            Text(
              "${widget.product.price.toString()} руб.",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: primaryColor,
              ),
            ),
            const Divider(),
            SizedBox(
              width: 1.sw,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () => addToCart(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 3,
                ),
                child: Text(
                  "В корзину",
                  style: TextStyle(color: Colors.white, fontSize: 18.sp),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
