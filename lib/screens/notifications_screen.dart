import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_farm/theme/app_theme.dart';
import 'package:smart_farm/widgets/farm_loader.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to view notifications'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('notifications')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: FarmLoader(color: AppTheme.primaryColor, size: 50));
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading notifications: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off, size: 80, color: Colors.black26),
                        SizedBox(height: 16),
                        Text('No notifications yet', style: TextStyle(fontSize: 18, color: Colors.black54)),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final title = data['title'] ?? 'Notification';
                    final body = data['body'] ?? '';
                    final timestamp = data['timestamp'] as Timestamp?;
                    
                    String timeAgo = 'Just now';
                    if (timestamp != null) {
                      final diff = DateTime.now().difference(timestamp.toDate());
                      if (diff.inDays > 0) {
                        timeAgo = '${diff.inDays} days ago';
                      } else if (diff.inHours > 0) {
                        timeAgo = '${diff.inHours} hours ago';
                      } else if (diff.inMinutes > 0) {
                        timeAgo = '${diff.inMinutes} mins ago';
                      }
                    }

                    return _buildNotification(
                      title: title,
                      description: body,
                      time: timeAgo,
                      icon: Icons.notifications_active,
                      iconColor: AppTheme.primaryColor,
                      bgColor: AppTheme.primaryColor.withOpacity(0.1),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildNotification({
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87))),
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
