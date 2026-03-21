import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_farm/widgets/farm_loader.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // Cache the last known list so items never vanish during transient loading states
  List<QueryDocumentSnapshot> _lastOrders = [];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: const Center(child: Text('Please log in to view your orders.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      backgroundColor: const Color(0xFFF6FAF2),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Update cache only when we have real data
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            _lastOrders = snapshot.data!.docs;
          }

          // Still loading and no cache yet — show spinner
          if (snapshot.connectionState == ConnectionState.waiting && _lastOrders.isEmpty) {
            return const Center(child: FarmLoader(size: 60, color: Color(0xFF2E7D32)));
          }

          // Confirmed empty from Firestore (not just loading)
          if (snapshot.connectionState != ConnectionState.waiting &&
              snapshot.hasData &&
              snapshot.data!.docs.isEmpty &&
              _lastOrders.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          // Use cached list so scroll never causes vanishing
          final orders = _lastOrders;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final order = orders[i].data() as Map<String, dynamic>;
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${orders[i].id}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Status: ${order['status'] ?? 'Unknown'}'),
                      Text('Total: ₹${order['totalAmount'] ?? '--'}'),
                      Text(
                          'Date: ${order['timestamp']?.toDate().toString().split(' ')[0] ?? '--'}'),
                      const SizedBox(height: 8),
                      const Text('Items:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...List<Widget>.from(
                        (order['items'] as List?)?.map((item) => Text(
                                '${item['productName']} x${item['quantity']} - ₹${item['total']}')) ??
                            [],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
