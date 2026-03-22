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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset('assets/images/logo.png', width: 28, height: 28),
                const SizedBox(width: 8),
                Text('Krushi Mithra', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
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
                  icon: Icon(Icons.notifications, color: Theme.of(context).iconTheme.color, size: 20),
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
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.headlineMedium?.color, height: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      TranslationService.translate('mandi_prices_subtitle'),
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    _buildSearchBar(context),
                    const SizedBox(height: 16),
                    _buildFilters(context),
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
                    _buildMarketAnalysisBanner(context),
                    const SizedBox(height: 16),
                    FloatingActionButton.extended(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(TranslationService.translate('post_crop_coming_soon'))),
                        );
                      },
                        backgroundColor: isDark ? Theme.of(context).primaryColor : const Color(0xFF1E2124),
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

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
          hintText: TranslationService.translate('search_crops_hint'),
          border: InputBorder.none,
          hintStyle: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(context, TranslationService.translate('nearby'), true, icon: Icons.near_me),
          const SizedBox(width: 8),
          _buildChip(context, TranslationService.translate('best_price'), false, icon: Icons.trending_up),
          const SizedBox(width: 8),
          _buildChip(context, TranslationService.translate('more_filters'), false, icon: Icons.tune),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, bool isSelected, {IconData? icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: isSelected ? null : Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.black54), size: 16),
            const SizedBox(width: 6),
          ],
          Text(label, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontWeight: FontWeight.bold, fontSize: 13)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                      color: isDark ? Colors.black.withOpacity(0.5) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Theme.of(context).primaryColor, size: 14),
                        const SizedBox(width: 4),
                        Text(TranslationService.translate('verified'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Theme.of(context).primaryColor)),
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
                    Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    Text(
                      price,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Theme.of(context).textTheme.bodySmall?.color, size: 14),
                        const SizedBox(width: 4),
                        Text(location, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                      ],
                    ),
                    Text(TranslationService.translate('per_quintal'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(TranslationService.translate('sell_flow_coming_soon'))),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                        label: Text(TranslationService.translate('sell'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.call, color: Theme.of(context).iconTheme.color, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(TranslationService.translate('call_feature_coming_soon'))),
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

  Widget _buildMarketAnalysisBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).primaryColor.withOpacity(0.1) : const Color(0xFFFBEBE4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE5C0B3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.bar_chart, color: isDark ? Colors.white70 : Colors.black87, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(TranslationService.translate('market_analysis'), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(height: 4),
                Text(
                  TranslationService.translate('market_analysis_desc'),
                  style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8), height: 1.3),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
