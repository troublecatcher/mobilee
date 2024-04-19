import 'package:flutter/material.dart';
import 'package:mobile/app/const.dart';
import 'package:mobile/features/purchase/cart_screen.dart';
import 'package:mobile/features/favorite/favorite_screen.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/auth/profile_screen.dart';

class BottomNavController extends StatefulWidget {
  const BottomNavController({super.key});

  @override
  BottomNavControllerState createState() => BottomNavControllerState();
}

class BottomNavControllerState extends State<BottomNavController> {
  final _pages = [
    const HomeScreen(),
    const FavoriteScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Продуктовый магазин",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 5,
        selectedItemColor: primaryColor,
        backgroundColor: Colors.white,
        unselectedItemColor: primaryColor,
        currentIndex: _currentIndex,
        selectedLabelStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Главная",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline), label: "Избранное"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Корзина",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Профиль",
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: _pages[_currentIndex],
    );
  }
}
