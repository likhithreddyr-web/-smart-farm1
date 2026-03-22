import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_farm/screens/cart_screen.dart';
import 'package:smart_farm/screens/product_detail_screen.dart';
import 'package:smart_farm/services/cart_service.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/screens/shop_screen.dart'; // to get Product model

class PesticidesScreen extends StatefulWidget {
  const PesticidesScreen({super.key});

  @override
  State<PesticidesScreen> createState() => _PesticidesScreenState();
}

class _PesticidesScreenState extends State<PesticidesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('pesticides').get();
      if (snapshot.docs.isEmpty) {
        // If collection is empty, seed it with the 60 base products
        await _seedDatabase();
        final newSnapshot = await _firestore.collection('pesticides').get();
        if (mounted) {
          setState(() {
            _products = newSnapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _products = snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching products from Firebase: $e");
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _seedDatabase() async {
    List<Product> initialProducts = List.generate(60, (index) {
      int iter = (index ~/ 12) + 1;
      int baseIndex = index % 12;
      
      List<Map<String, dynamic>> bases = [
        {'name': 'Neem Oil Spray', 'category': 'Organic Insecticide', 'basePrice': 100.0, 'quantity': '1 Litre', 'brand': 'EcoGrow', 'desc': 'Controls aphids and mites', 'crops': 'Vegetables, Fruits', 'url': 'https://images.unsplash.com/photo-1598514982846-9c8b5c6a6b64'},
        {'name': 'Urea', 'category': 'Fertilizer', 'basePrice': 120.0, 'quantity': '1 Kg', 'brand': 'IFFCO', 'desc': 'High nitrogen fertilizer', 'crops': 'All crops', 'url': 'https://images.unsplash.com/photo-1589927986089-35812388d1f4'},
        {'name': 'DAP', 'category': 'Fertilizer', 'basePrice': 140.0, 'quantity': '1 Kg', 'brand': 'Coromandel', 'desc': 'Nitrogen + phosphorus', 'crops': 'Wheat, Rice', 'url': 'https://images.unsplash.com/photo-1601004890684-d8cbf643f5f2'},
        {'name': 'Potash', 'category': 'Fertilizer', 'basePrice': 160.0, 'quantity': '1 Kg', 'brand': 'Tata Rallis', 'desc': 'Improves yield quality', 'crops': 'All crops', 'url': 'https://images.unsplash.com/photo-1560493676-04071c5f467b'},
        {'name': 'Zinc Sulphate', 'category': 'Micronutrient', 'basePrice': 180.0, 'quantity': '1 Kg', 'brand': 'Kribhco', 'desc': 'Corrects zinc deficiency', 'crops': 'Rice, Wheat', 'url': 'https://images.unsplash.com/photo-1592928302636-c83cf1e1c1f3'},
        {'name': 'Seaweed Extract', 'category': 'Growth Booster', 'basePrice': 200.0, 'quantity': '1 Litre', 'brand': 'AgriBoost', 'desc': 'Enhances growth', 'crops': 'Vegetables', 'url': 'https://images.unsplash.com/photo-1604908177522-4028c5a4b4d2'},
        {'name': 'Glyphosate', 'category': 'Herbicide', 'basePrice': 220.0, 'quantity': '1 Kg', 'brand': 'Roundup', 'desc': 'Weed control', 'crops': 'Non-crop', 'url': 'https://images.unsplash.com/photo-1598514982846-9c8b5c6a6b64'},
        {'name': 'Carbendazim', 'category': 'Fungicide', 'basePrice': 240.0, 'quantity': '1 Kg', 'brand': 'UPL', 'desc': 'Controls fungal diseases', 'crops': 'Fruits', 'url': 'https://images.unsplash.com/photo-1589927986089-35812388d1f4'},
        {'name': 'Imidacloprid', 'category': 'Insecticide', 'basePrice': 260.0, 'quantity': '1 Kg', 'brand': 'Syngenta', 'desc': 'Controls sucking pests', 'crops': 'Cotton', 'url': 'https://images.unsplash.com/photo-1601004890684-d8cbf643f5f2'},
        {'name': 'Bio Compost', 'category': 'Organic Fertilizer', 'basePrice': 280.0, 'quantity': '1 Kg', 'brand': 'GreenGrow', 'desc': 'Improves soil health', 'crops': 'All crops', 'url': 'https://images.unsplash.com/photo-1560493676-04071c5f467b'},
        {'name': 'Azospirillum', 'category': 'Bio Fertilizer', 'basePrice': 300.0, 'quantity': '1 Kg', 'brand': 'BioAgri', 'desc': 'Nitrogen fixing bacteria', 'crops': 'Cereals', 'url': 'https://images.unsplash.com/photo-1592928302636-c83cf1e1c1f3'},
        {'name': 'Trichoderma', 'category': 'Bio Fungicide', 'basePrice': 320.0, 'quantity': '1 Kg', 'brand': 'AgriLife', 'desc': 'Prevents root diseases', 'crops': 'Vegetables', 'url': 'https://images.unsplash.com/photo-1604908177522-4028c5a4b4d2'},
      ];
      
      var base = bases[baseIndex];
      double price = (base['basePrice'] as double) + (iter - 1) * 15.0;
      
      return Product(
        name: '${base['name']} $iter',
        image: base['url'] as String,
        currentPrice: price,
        originalPrice: price + 50.0,
        discountPercent: ((50.0 / (price + 50.0)) * 100).round(),
        likes: 120 + index * 5,
        category: base['category'] as String,
        quantity: base['quantity'] as String,
        brand: base['brand'] as String,
        description: base['desc'] as String,
        suitableCrops: base['crops'] as String,
      );
    });
    
    WriteBatch batch = _firestore.batch();
    for (var prod in initialProducts) {
      DocumentReference docRef = _firestore.collection('pesticides').doc();
      batch.set(docRef, prod.toMap());
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.currentLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              Expanded(
                child: _isLoading 
                    ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
                    : _buildProductGrid(),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(TranslationService.translate('pesticides_booking'), style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold)),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
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
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
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



  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65, 
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_products[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10), 
                Expanded(
                  child: Center(
                    child: Image.network(
                      product.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 50, color: isDark ? Colors.white12 : Colors.black12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.brand} • ${product.quantity}',
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54),
                ),
                Text(
                  product.category,
                  style: TextStyle(fontSize: 10, color: isDark ? Theme.of(context).primaryColor : Colors.green),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('₹${product.currentPrice.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    const SizedBox(width: 8),
                    Text('₹${product.originalPrice.toInt()}', style: TextStyle(color: isDark ? Colors.white24 : Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough)),
                  ],
                ),
                const SizedBox(height: 4),
                // ...existing code...
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        CartService.instance.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} ${TranslationService.translate('added_to_cart')}'),
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'VIEW',
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(4)), 
                        child: const Icon(Icons.add, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            top: 12,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFFE91E63), 
                borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
              ),
              child: Text('${product.discountPercent}%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: InkWell(
              onTap: () {
                setState(() {
                  product.isLiked = !product.isLiked;
                });
              },
              child: Column(
                children: [
                  Icon(
                    product.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: product.isLiked ? Colors.red : (isDark ? Colors.white24 : Colors.grey),
                    size: 16,
                  ),
                  const SizedBox(height: 2),
                  Text('${product.isLiked ? product.likes + 1 : product.likes} Likes', style: TextStyle(color: isDark ? Colors.white24 : Colors.grey, fontSize: 8)),
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}
