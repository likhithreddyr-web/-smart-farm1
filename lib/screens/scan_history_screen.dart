import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_farm/widgets/farm_loader.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan History'),
          backgroundColor: const Color(0xFFF5F2EA),
        ),
        body: const Center(child: Text('Please log in to see history.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      appBar: AppBar(
        title: const Text('Scan History', style: TextStyle(color: Color(0xFF3D3D3D), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF5F2EA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF8B9467)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('scans')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: FarmLoader(size: 60, color: Color(0xFF8B9467)));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading history: \${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No scans yet. Start scanning your plants!',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
              ),
            );
          }

          final scans = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: scans.length,
            itemBuilder: (context, index) {
              final data = scans[index].data() as Map<String, dynamic>;
              final result = data['result'] ?? 'No result';
              final imagePath = data['imagePath'];
              final timestamp = data['timestamp'] as Timestamp?;
              
              final dateStr = timestamp != null 
                ? timestamp.toDate().toLocal().toString().split('.')[0]
                : 'Unknown Date';

              return Card(
                color: Colors.white,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.history, color: Color(0xFF8B9467)),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: Color(0xFF757575),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (imagePath != null && File(imagePath).existsSync())
                         ClipRRect(
                           borderRadius: BorderRadius.circular(8),
                           child: Image.file(
                             File(imagePath),
                             height: 150,
                             width: double.infinity,
                             fit: BoxFit.cover,
                           ),
                         ),
                      if (imagePath != null && File(imagePath).existsSync())
                         const SizedBox(height: 12),
                      Text(
                        result,
                        style: const TextStyle(
                          color: Color(0xFF3D3D3D),
                          fontSize: 14,
                        ),
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
