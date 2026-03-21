import 'package:flutter/material.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/theme/app_theme.dart';
import 'package:smart_farm/screens/notifications_screen.dart';

class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.currentLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset('assets/images/logo.png', width: 28, height: 28),
                const SizedBox(width: 8),
                const Text('Krushi Mithra', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.black87, size: 20),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                  },
                ),
              )
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationService.translate('mandi_prices_title'),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      TranslationService.translate('mandi_prices_subtitle'),
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildFilters(),
                    const SizedBox(height: 20),
                    _buildCropCard(
                      context,
                      name: 'Wheat (Kanak)',
                      location: 'Karnal Mandi, Haryana',
                      price: '₹2,100',
                      color: Colors.amber[200]!,
                      verified: true,
                    ),
                    const SizedBox(height: 16),
                    _buildCropCard(
                      context,
                      name: 'Basmati Rice',
                      location: 'Amritsar Mandi, Punjab',
                      price: '₹3,450',
                      color: Colors.brown[200]!,
                      verified: false,
                    ),
                    const SizedBox(height: 16),
                    _buildCropCard(
                      context,
                      name: 'Maize (Corn)',
                      location: 'Nashik Mandi, Maharashtra',
                      price: '₹1,850',
                      color: Colors.yellow[300]!,
                      verified: false,
                    ),
                    const SizedBox(height: 180), // Padding for the floating banner and FAB
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 30, // Account for bottom nav indirectly or if placed manually
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildMarketAnalysisBanner(),
                    const SizedBox(height: 16),
                    FloatingActionButton.extended(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post crop flow coming soon!')),
                        );
                      },
                      backgroundColor: const Color(0xFF1E2124),
                      extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
                      elevation: 0,
                      icon: const Icon(Icons.add_circle, color: Colors.white),
                      label: Text(TranslationService.translate('post_your_crop'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: Colors.black54),
          hintText: TranslationService.translate('search_crops_hint'),
          border: InputBorder.none,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(TranslationService.translate('nearby'), true, icon: Icons.near_me),
          const SizedBox(width: 8),
          _buildChip(TranslationService.translate('best_price'), false, icon: Icons.trending_up),
          const SizedBox(width: 8),
          _buildChip(TranslationService.translate('more_filters'), false, icon: Icons.tune),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: isSelected ? Colors.white : Colors.black54, size: 16),
            const SizedBox(width: 6),
          ],
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCropCard(
    BuildContext context, {
    required String name,
    required String location,
    required String price,
    required Color color,
    required bool verified,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              if (verified)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: AppTheme.primaryColor, size: 14),
                        const SizedBox(width: 4),
                        Text(TranslationService.translate('verified'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(
                      price,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.black54, size: 14),
                        const SizedBox(width: 4),
                        Text(location, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                    Text(TranslationService.translate('per_quintal'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sell flow coming soon!')),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                        label: Text(TranslationService.translate('sell'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.call, color: Colors.black87, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Call feature coming soon!')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMarketAnalysisBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEBE4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE5C0B3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bar_chart, color: Colors.black87, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Market Analysis', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(
                  'Wheat prices have increased by 4% in the last 7 days. This might be the best time to list your stock.',
                  style: TextStyle(fontSize: 12, color: Colors.black87.withOpacity(0.8), height: 1.3),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
