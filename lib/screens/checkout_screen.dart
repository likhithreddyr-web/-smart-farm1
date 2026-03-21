import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_farm/services/cart_service.dart';
import 'package:smart_farm/widgets/farm_loader.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  String _selectedPaymentMethod = 'Cash on Delivery';
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (CartService.instance.items.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'guest_\${DateTime.now().millisecondsSinceEpoch}';

      final cartItems = CartService.instance.items.values.map((item) {
        return {
          'productName': item.product.name,
          'price': item.product.currentPrice,
          'quantity': item.quantity,
          'total': item.product.currentPrice * item.quantity,
        };
      }).toList();

      final orderData = {
        'userId': userId,
        'customerName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'deliveryAddress': _addressController.text.trim(),
        'paymentMethod': _selectedPaymentMethod,
        'items': cartItems,
        'totalAmount': CartService.instance.totalPrice,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Save to global orders collection (or users/{uid}/orders)
      await FirebaseFirestore.instance.collection('orders').add(orderData).timeout(const Duration(seconds: 15));

      try {
        await _sendEmailNotification(orderData);
        if (mounted) {
          _showSuccessDialog();
        }
      } catch (e) {
        debugPrint('Email sending failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order saved, but email failed: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
          _showSuccessDialog();
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    CartService.instance.clearCart();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text('Order Successful!', style: TextStyle(color: Color(0xFF1B4332))),
          ],
        ),
        content: const Text(
          'Your order has been placed successfully and will be delivered soon.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Pop the dialog
                Navigator.pop(context);
                // Pop the checkout screen (back to Cart or Shop)
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4332),
                foregroundColor: Colors.white,
              ),
              child: const Text('Back to Shop'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmailNotification(Map<String, dynamic> orderData) async {
    // TODO: Replace these with your actual EmailJS credentials
    const serviceId = 'service_b38339x';
    const templateId = 'template_s8h0tgk';
    const userId = 'esDIKQjQ5K05XKr5t';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    
    // Calculate total quantity and simple product names string
    int totalQuantity = 0;
    List<String> productNames = [];
    for (var item in orderData['items']) {
      totalQuantity += (item['quantity'] as num).toInt();
      productNames.add(item['productName'].toString());
    }

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'to_email': orderData['email'], // Make sure 'To Email' field in EmailJS dashboard is set to {{to_email}}
          'user_name': orderData['customerName'],
          'order_id': 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          'product_name': productNames.join(', '),
          'quantity': totalQuantity.toString(),
          'price': orderData['totalAmount'].toString(),
          'address': orderData['deliveryAddress'],
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isProcessing
          ? const Center(child: FarmLoader(size: 70, color: Color(0xFF1B4332)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Delivery Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 16),
                    
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your email address';
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Please enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Address Field
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Full Delivery Address',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 30),
                          child: Icon(Icons.location_on_outlined),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your delivery address' : null,
                    ),
                    
                    const SizedBox(height: 32),
                    const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 16),
                    
                    // Payment Method Options
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          RadioListTile(
                            value: 'Cash on Delivery',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (val) => setState(() => _selectedPaymentMethod = val.toString()),
                            title: const Text('Cash on Delivery'),
                            secondary: const Icon(Icons.money, color: Colors.green),
                            activeColor: const Color(0xFF1B4332),
                          ),
                          const Divider(height: 1),
                          RadioListTile(
                            value: 'Credit/Debit Card',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (val) => setState(() => _selectedPaymentMethod = val.toString()),
                            title: const Text('Credit/Debit Card'),
                            secondary: const Icon(Icons.credit_card, color: Colors.blue),
                            activeColor: const Color(0xFF1B4332),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    // Order Summary
                     Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8F6), // Very light green
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                          Text(
                            '₹${CartService.instance.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63), // Pinkish red to match discount badge
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: const Text('Place Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
