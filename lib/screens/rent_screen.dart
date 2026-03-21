import 'package:flutter/material.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/theme/app_theme.dart';
import 'package:smart_farm/screens/notifications_screen.dart';

class RentScreen extends StatelessWidget {
  const RentScreen({super.key});

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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(TranslationService.translate('available_now'), style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(TranslationService.translate('professional_machinery'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(TranslationService.translate('all_equipment'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                _buildFilters(),
                const SizedBox(height: 20),
                _buildMachineryCard(
                  context,
                  name: 'Mahindra Tractor',
                  distance: 'Kisan Tractor Garage, Pune',
                  price: '₹500',
                  rating: '4.8',
                  color: Colors.red[300]!,
                  spec1Label: 'Power',
                  spec1Value: '50 HP',
                  spec2Label: 'Fuel',
                  spec2Value: 'Diesel',
                ),
                const SizedBox(height: 24),
                _buildMachineryCard(
                  context,
                  name: 'Rotavator',
                  distance: 'Agri Implements Hub, Nashik',
                  price: '₹300',
                  rating: '4.5',
                  color: Colors.orange[300]!,
                  spec1Label: 'Width',
                  spec1Value: '6 Feet',
                  spec2Label: 'Condition',
                  spec2Value: 'New',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip(TranslationService.translate('all_equipment'), true),
          const SizedBox(width: 12),
          _buildCategoryChip(TranslationService.translate('tractors'), false),
          const SizedBox(width: 24),
          _buildCategoryChip(TranslationService.translate('tillage'), false),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildMachineryCard(
    BuildContext context, {
    required String name,
    required String distance,
    required String price,
    required String rating,
    required Color color,
    required String spec1Label,
    required String spec1Value,
    required String spec2Label,
    required String spec2Value,
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
                height: 180,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: AppTheme.primaryColor, size: 14),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                        Text(distance, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                    Text(TranslationService.translate('per_hour'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F6F3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(spec1Label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                            const SizedBox(height: 4),
                            Text(spec1Value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F6F3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(spec2Label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                            const SizedBox(height: 4),
                            Text(spec2Value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(TranslationService.translate('booking_coming_soon'))),
                        );
                      },
                    child: Text(TranslationService.translate('book_now'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F6F3),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Call feature coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.call, color: Colors.black87, size: 18),
                    label: const Text('Call Owner', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
