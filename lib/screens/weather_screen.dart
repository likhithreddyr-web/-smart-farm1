import 'package:flutter/material.dart';
import 'package:smart_farm/screens/notifications_screen.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/services/push_notification_service.dart';
import 'dart:ui';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.currentLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6FAF2), // Light greenish background
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Weather Forecast', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none, color: Colors.black87),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildCurrentWeatherCard(),
                  const SizedBox(height: 24),
                  _buildRainfallWarning(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      PushNotificationService().showSimulatedNotification(
                        title: 'Severe Storm Warning',
                        body: 'Heavy showers expected in your area in 10 minutes. Please secure your machinery.',
                      );
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Simulate Weather Alert (Test)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCCB3),
                      foregroundColor: const Color(0xFF4A1E0E),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSoilMoisture(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildUvIndex()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildAirQuality()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildForecastHeader(),
                  const SizedBox(height: 16),
                  _buildForecastList(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentWeatherCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A), Color(0xFFF1F8E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFA5D6A7).withOpacity(0.25),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
        // Glassmorphism effect
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationService.translate('current_location'),
                        style: TextStyle(
                          color: Color(0xFFA5D6A7),
                          fontSize: 12,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Green Valley\nFarm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Color(0xFF2E7D32).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.sync, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('Updated\n2m ago', style: TextStyle(color: Colors.white, fontSize: 12, height: 1.2)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 28),
              Center(
                child: Column(
                  children: [
                    // Animated weather icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, scale, child) => Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFFD54F).withOpacity(0.18),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.wb_sunny_outlined, color: Color(0xFFFFD54F), size: 88),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('28', style: TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.w900, height: 1)),
                        Text('°C', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.5)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sunny & Clear',
                      style: TextStyle(
                        color: Color(0xFFA5D6A7),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.only(top: 24),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white24, width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherMetric(TranslationService.translate('humidity'), '42%'),
                    Container(height: 30, width: 1, color: Colors.white30),
                    _buildWeatherMetric(TranslationService.translate('wind'), '12km/h'),
                    Container(height: 30, width: 1, color: Colors.white30),
                    _buildWeatherMetric(TranslationService.translate('rainfall'), '0.0mm'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFA1B5AA), fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRainfallWarning() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCCB3), // Peach orange
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF4A1E0E), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(TranslationService.translate('rainfall_warning'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A1E0E))),
                const SizedBox(height: 8),
                Text(
                  'Heavy showers expected in the next 4 hours (approx. 15mm). Ensure irrigation systems are paused and drainage gates are clear.',
                  style: TextStyle(color: Color(0xFF6A3B2A), fontSize: 13, height: 1.4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSoilMoisture() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(TranslationService.translate('soil_moisture_label'), style: const TextStyle(color: Color(0xFF986B5A), fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('64%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          SizedBox(
            height: 40,
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(15, const Color(0xFFA0C2A7)),
                _buildBar(25, const Color(0xFFA0C2A7)),
                _buildBar(30, const Color(0xFFA0C2A7)),
                _buildBar(35, const Color(0xFFA0C2A7)),
                _buildBar(35, const Color(0xFF133E2B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUvIndex() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF0F3ED), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.device_thermostat, color: Color(0xFF133E2B)),
          const SizedBox(height: 24),
          Text(TranslationService.translate('uv_index'), style: const TextStyle(color: Color(0xFF986B5A), fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text('7.2', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(width: 8),
              Text('High', style: TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAirQuality() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF0F3ED), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.air, color: Color(0xFF133E2B)),
          const SizedBox(height: 24),
          Text(TranslationService.translate('air_quality'), style: const TextStyle(color: Color(0xFF986B5A), fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text('42', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(width: 8),
              Text('Good', style: TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 6,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
    );
  }

  Widget _buildForecastHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(TranslationService.translate('next_5_days'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(TranslationService.translate('see_full_report'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF133E2B))),
      ],
    );
  }

  Widget _buildForecastList() {
    return Column(
      children: [
        _buildForecastItem('Tomorrow', Icons.cloudy_snowing, 'Cloudy', '24°', '18°', const Color(0xFF6A3B2A)), // Brown color
        const SizedBox(height: 12),
        _buildForecastItem('Wed', Icons.cloud, 'Rainy', '21°', '16°', const Color(0xFF1A3B36)), // Dark gray/green
        const SizedBox(height: 12),
        _buildForecastItem('Thu', Icons.wb_sunny_outlined, 'Partly', '26°', '19°', const Color(0xFFB57041)), // Orange
      ],
    );
  }

  Widget _buildForecastItem(String day, IconData icon, String condition, String high, String low, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 80, child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              SizedBox(width: 70, child: Text(condition, style: const TextStyle(color: Colors.black54, fontSize: 14))),
            ],
          ),
          Row(
            children: [
              Text(high, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 12),
              Text(low, style: const TextStyle(color: Colors.black45, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }
}
