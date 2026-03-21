import 'package:flutter/material.dart';
import 'package:smart_farm/screens/scanner_screen.dart';
import 'package:smart_farm/screens/sell_screen.dart';
import 'package:smart_farm/screens/rent_screen.dart';
import 'package:smart_farm/screens/weather_screen.dart';
import 'package:smart_farm/screens/shop_screen.dart';
import 'package:smart_farm/screens/profile_screen.dart';
import 'package:smart_farm/screens/soil_moisture_predictor_screen.dart';
import 'package:smart_farm/screens/notifications_screen.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.currentLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            ),
            title: Text(TranslationService.translate('home') ?? 'AgriGrow'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(context),
                const SizedBox(height: 20),
                _buildWeatherCard(),
                const SizedBox(height: 20),
                _buildScanCard(),
                const SizedBox(height: 20),
                _buildFunctionGrid(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('28°C', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF2F5232))),
                const Icon(Icons.cloud, color: Color(0xFF2F5232), size: 44),
              ],
            ),
            const SizedBox(height: 4),
            Text(TranslationService.translate('sunny_clear'), style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _weatherMetric('Humidity', '65%', Icons.water_drop),
                _weatherMetric('Wind', '8 km/h', Icons.air),
                _weatherMetric('Rain', '0 mm', Icons.umbrella),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherMetric(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _buildScanCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationService.translate('scan_crop'),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  TranslationService.translate('ai_analysis_desc'),
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.2),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildFunctionGrid(BuildContext context) {
    final items = [
      {'title': 'scan_crop', 'icon': Icons.camera_alt, 'color': Colors.blue.shade50, 'onTap': () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
      }},
      {'title': 'sell_crops', 'icon': Icons.storefront, 'color': Colors.orange.shade50, 'onTap': () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SellScreen()));
      }},
      {'title': 'hire_machinery', 'icon': Icons.build, 'color': Colors.green.shade50, 'onTap': () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RentScreen()));
      }},
      {'title': 'check_prices', 'icon': Icons.trending_up, 'color': Colors.purple.shade50, 'onTap': () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SellScreen()));
      }},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
              letterSpacing: 1.1,
            )),
        const SizedBox(height: 16),
        GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return InkWell(
              onTap: item['onTap'] as void Function()?,
              borderRadius: BorderRadius.circular(20),
              splashColor: AppTheme.accentColor.withOpacity(0.2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item['color'] as Color,
                      AppTheme.accentColor.withOpacity(0.7),
                      AppTheme.backgroundColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (item['color'] as Color).withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.highlightColor.withOpacity(0.18),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        TranslationService.translate(item['title'] as String),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                          letterSpacing: 0.7,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return InkWell(
      onTap: () {
        showSearch(context: context, delegate: AppSearchDelegate());
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text(
              TranslationService.translate('search') ?? 'Search app features...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class AppSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> searchItems = [
    {
      'title': 'Weather Forecast',
      'icon': Icons.wb_sunny,
      'screen': const WeatherScreen()
    },
    {
      'title': 'Scan Crop Disease',
      'icon': Icons.camera_alt,
      'screen': const ScannerScreen()
    },
    {
      'title': 'Sell Crops (Mandi)',
      'icon': Icons.storefront,
      'screen': const SellScreen()
    },
    {
      'title': 'Hire Machinery',
      'icon': Icons.build,
      'screen': const RentScreen()
    },
    {
      'title': 'Soil Moisture Predictor',
      'icon': Icons.shower,
      'screen': const SoilMoisturePredictorScreen()
    },
    {
      'title': 'Shop (Buy inputs)',
      'icon': Icons.shopping_cart,
      'screen': const ShopScreen()
    },
    {
      'title': 'Profile',
      'icon': Icons.person,
      'screen': const ProfileScreen()
    },
    {
      'title': 'Notifications',
      'icon': Icons.notifications,
      'screen': const NotificationsScreen()
    },
  ];

  @override
  String get searchFieldLabel => TranslationService.translate('search') ?? 'Search app features...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.grey),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final suggestions = searchItems.where((item) {
      return (item['title'] as String).toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (suggestions.isEmpty) {
      return const Center(child: Text('No features found', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item['icon'] as IconData, color: AppTheme.primaryColor, size: 20),
          ),
          title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item['screen'] as Widget),
            );
          },
        );
      },
    );
  }
}

