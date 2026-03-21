import 'package:flutter/material.dart';
import 'package:smart_farm/screens/notifications_screen.dart';
import 'package:smart_farm/screens/cart_screen.dart';
import 'package:smart_farm/services/cart_service.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/screens/pesticides_screen.dart';
import 'package:smart_farm/screens/machinery_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.currentLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildCategoryCard(
                      TranslationService.translate('seeds') ?? 'Seeds',
                      Icons.grass,
                      const Color(0xFF1E3A2B),
                      () {},
                    ),
                    _buildCategoryCard(
                      TranslationService.translate('pesticides_booking'),
                      Icons.science,
                      const Color(0xFF1E3A2B),
                      () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PesticidesScreen()));
                      },
                    ),
                    _buildCategoryCard(
                      TranslationService.translate('fertilizers') ?? 'Fertilizers',
                      Icons.compost,
                      const Color(0xFF1E3A2B),
                      () {},
                    ),
                    _buildCategoryCard(
                      TranslationService.translate('equipment') ?? 'Equipment',
                      Icons.agriculture,
                      const Color(0xFF1E3A2B),
                      () {},
                    ),
                    _buildCategoryCard(
                      'Machinery Rental',
                      Icons.construction,
                      const Color(0xFF1B5E20),
                      () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MachineryScreen()));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D3D3D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text('Krushi Angadi', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      actions: [
        IconButton(icon: const Icon(Icons.search, color: Colors.black54), onPressed: () {}),
        IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black54), onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
        }),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: ListenableBuilder(
                listenable: CartService.instance,
                builder: (context, child) {
                  final totalItems = CartService.instance.totalItems;
                  if (totalItems == 0) return const SizedBox.shrink();
                  
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFF1976D2), shape: BoxShape.circle),
                    child: Text('$totalItems', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            )
          ],
        ),
      ],
    );
  }
}

class Product {
  final String id;
  final String name;
  final String image;
  final double currentPrice;
  final double originalPrice;
  final int discountPercent;
  final int likes;
  bool isLiked;
  final String category;
  final String quantity;
  final String brand;
  final String description;
  final String suitableCrops;

  Product({
    this.id = '',
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.originalPrice,
    required this.discountPercent,
    required this.likes,
    this.isLiked = false,
    this.category = '',
    this.quantity = '',
    this.brand = '',
    this.description = '',
    this.suitableCrops = '',
  });

  factory Product.fromMap(Map<String, dynamic> map, String docId) {
    return Product(
      id: docId,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      currentPrice: map['currentPrice']?.toDouble() ?? 0.0,
      originalPrice: map['originalPrice']?.toDouble() ?? 0.0,
      discountPercent: map['discountPercent']?.toInt() ?? 0,
      likes: map['likes']?.toInt() ?? 0,
      category: map['category'] ?? '',
      quantity: map['quantity'] ?? '',
      brand: map['brand'] ?? '',
      description: map['description'] ?? '',
      suitableCrops: map['suitableCrops'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'currentPrice': currentPrice,
      'originalPrice': originalPrice,
      'discountPercent': discountPercent,
      'likes': likes,
      'category': category,
      'quantity': quantity,
      'brand': brand,
      'description': description,
      'suitableCrops': suitableCrops,
    };
  }
}
