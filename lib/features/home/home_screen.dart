import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/app/const.dart';
import 'package:mobile/features/home/custom_search_delegate.dart';
import 'package:mobile/features/home/product.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final List<String> _carouselImages = [];
  var _dotPosition = 0;
  List<Product> products = [];
  final _firestoreInstance = FirebaseFirestore.instance;

  fetchCarouselImages() async {
    if (mounted) {
      await _firestoreInstance
          .collection("carousel-slider")
          .get()
          .then((value) {
        setState(() {
          for (int i = 0; i < value.docs.length; i++) {
            _carouselImages.add(
              value.docs[i]["img-path"],
            );
          }
        });
      });
    }
  }

  fetchProducts() async {
    if (mounted) {
      await _firestoreInstance.collection("products").get().then((qn) {
        setState(() {
          products = qn.docs.map((doc) {
            return Product.fromFirestore(doc);
          }).toList();
        });
      });
    }
  }

  @override
  void initState() {
    fetchCarouselImages();
    fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      borderSide: BorderSide(color: Colors.blue)),
                  enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      borderSide:
                          BorderSide(color: Color.fromRGBO(24, 24, 27, 1))),
                  hintText: "Найти...",
                  hintStyle: TextStyle(fontSize: 15.sp),
                ),
                onTap: () => showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(products: products),
                ).then(
                  (product) {
                    if (product != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetails(product),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            AspectRatio(
              aspectRatio: 3.5,
              child: CarouselSlider(
                  items: _carouselImages
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(left: 3, right: 3),
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(item),
                                      fit: BoxFit.fitWidth)),
                            ),
                          ))
                      .toList(),
                  options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 2),
                      enlargeCenterPage: true,
                      viewportFraction: 0.8,
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      onPageChanged: (val, carouselPageChangedReason) {
                        setState(() {
                          _dotPosition = val;
                        });
                      })),
            ),
            SizedBox(
              height: 10.h,
            ),
            DotsIndicator(
              dotsCount: _carouselImages.isEmpty ? 1 : _carouselImages.length,
              position: _dotPosition,
              decorator: DotsDecorator(
                activeColor: primaryColor,
                color: primaryColor.withOpacity(0.5),
                spacing: const EdgeInsets.all(2),
                activeSize: const Size(8, 8),
                size: const Size(6, 6),
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 1),
                itemBuilder: (_, index) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetails(products[index]),
                      ),
                    ),
                    child: Card(
                      elevation: 3,
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 2,
                            child: Image.network(
                              products[index].images[0],
                            ),
                          ),
                          Text(products[index].name),
                          Text("${products[index].price.toString()} руб."),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
