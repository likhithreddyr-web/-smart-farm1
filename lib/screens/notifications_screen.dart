import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_farm/theme/app_theme.dart';
import 'package:smart_farm/widgets/farm_loader.dart';
import 'package:smart_farm/services/translation_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(TranslationService.translate('notifications'), style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold)),
      ),
      body: user == null
          ? Center(child: Text(TranslationService.translate('login_to_see_notifications')))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('notifications')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: FarmLoader(color: Theme.of(context).primaryColor, size: 50));
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('${TranslationService.translate('error')}: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off, size: 80, color: isDark ? Colors.white24 : Colors.black26),
                        const SizedBox(height: 16),
                        Text(TranslationService.translate('no_notifications'), style: TextStyle(fontSize: 18, color: isDark ? Colors.white60 : Colors.black54)),
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
                    
                    String timeAgo = TranslationService.translate('just_now');
                    if (timestamp != null) {
                      final diff = DateTime.now().difference(timestamp.toDate());
                      if (diff.inDays > 0) {
                        timeAgo = '${diff.inDays} ${TranslationService.translate('days_ago')}';
                      } else if (diff.inHours > 0) {
                        timeAgo = '${diff.inHours} ${TranslationService.translate('hours_ago')}';
                      } else if (diff.inMinutes > 0) {
                        timeAgo = '${diff.inMinutes} ${TranslationService.translate('mins_ago')}';
                      }
                    }

                    return _buildNotification(
                      context: context,
                      title: title,
                      description: body,
                      time: timeAgo,
                      icon: Icons.notifications_active,
                      iconColor: Theme.of(context).primaryColor,
                      bgColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildNotification({
    required BuildContext context,
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
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
                    Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color))),
                    Text(time, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
