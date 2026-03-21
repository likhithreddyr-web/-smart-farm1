import 'package:flutter/material.dart';
import 'package:smart_farm/screens/shop_screen.dart'; // for Product
import 'package:smart_farm/services/cart_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F0F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4C53A5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Product', style: TextStyle(color: Color(0xFF4C53A5), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              widget.product.isLiked ? Icons.favorite : Icons.favorite, // Heart icon reference is always seemingly red if liked? Wait, let's keep it simple.
              color: widget.product.isLiked ? Colors.red : const Color(0xFFF44336),
            ),
            onPressed: () {
              setState(() {
                widget.product.isLiked = !widget.product.isLiked;
              });
            },
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${(widget.product.currentPrice * quantity).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4C53A5)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  CartService.instance.addMultipleToCart(widget.product, quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $quantity x ${widget.product.name} to cart'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C53A5),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                label: const Text('Add To Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Container(
              height: 350,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Center(
                child: Image.network(
                  widget.product.image,
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 100, color: Colors.black12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4C53A5)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index <= 3 ? Icons.favorite : Icons.favorite,
                            color: index <= 3 ? const Color(0xFF4C53A5) : Colors.grey.shade400,
                            size: 18,
                          );
                        }),
                      ),
                      Row(
                        children: [
                          _buildQtyBtn(Icons.remove, () {
                            if (quantity > 1) {
                              setState(() => quantity--);
                            }
                          }),
                          const SizedBox(width: 12),
                          Text(quantity.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4C53A5))),
                          const SizedBox(width: 12),
                          _buildQtyBtn(Icons.add, () {
                            setState(() => quantity++);
                          }),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.product.description.isEmpty ? 'This is a more detailed description of the product. you can write here more about the product. this is lengthy description.' : widget.product.description,
                    style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Sizes / Attributes
                  Row(
                    children: [
                      const Text('Brand: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4C53A5))),
                      const SizedBox(width: 12),
                      _buildChip(widget.product.brand),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Crops: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4C53A5))),
                      const SizedBox(width: 12),
                      _buildChip(widget.product.suitableCrops),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Size: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4C53A5))),
                      const SizedBox(width: 22),
                      _buildChip(widget.product.quantity),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
          ]
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF4C53A5)),
      ),
    );
  }

  Widget _buildChip(String label) {
    if (label.isEmpty) label = 'N/A';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }
}
