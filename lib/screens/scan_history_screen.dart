import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_farm/widgets/farm_loader.dart';
import 'package:smart_farm/services/translation_service.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(TranslationService.translate('scan_history')),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          titleTextStyle: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        body: Center(child: Text(TranslationService.translate('login_to_see_history'), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color))),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? Theme.of(context).primaryColor : const Color(0xFF8B9467);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(TranslationService.translate('scan_history'), style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: accentColor),
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
            return Center(child: FarmLoader(size: 60, color: accentColor));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading history: \${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                TranslationService.translate('no_scans_yet'),
                style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF9E9E9E), fontSize: 16),
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
                color: Theme.of(context).cardColor,
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
                          Icon(Icons.history, color: accentColor),
                          Text(
                            dateStr,
                            style: TextStyle(
                              color: isDark ? Colors.white60 : const Color(0xFF757575),
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
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
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
