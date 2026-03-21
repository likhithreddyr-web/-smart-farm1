import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:smart_farm/screens/get_started_screen.dart';
import 'package:smart_farm/screens/home_screen.dart';
import 'package:smart_farm/screens/login_screen.dart';
import 'package:smart_farm/screens/profile_screen.dart';
import 'package:smart_farm/screens/shop_screen.dart';
import 'package:smart_farm/screens/weather_screen.dart';
import 'package:smart_farm/screens/scanner_screen.dart';
import 'package:smart_farm/screens/soil_moisture_predictor_screen.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm/services/theme_service.dart';
import 'package:smart_farm/theme/app_theme.dart';
import 'package:smart_farm/widgets/farm_loader.dart';
import 'package:smart_farm/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA_TKpjk8D3vrqjkA5uoQLzSc3QUnbsplc",
      authDomain: "soil-e7d41.firebaseapp.com",
      projectId: "soil-e7d41",
      storageBucket: "soil-e7d41.firebasestorage.app",
      messagingSenderId: "585603348069",
      appId: "1:585603348069:android:a3fa12276959182284388c",
      databaseURL: "https://soil-e7d41-default-rtdb.asia-southeast1.firebasedatabase.app",
    ),
  );
  
  await PushNotificationService().initialize();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const SmartFarmApp(),
    ),
  );
}

class SmartFarmApp extends StatelessWidget {
  const SmartFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return MaterialApp(
      title: 'Krushi Mithra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      builder: (context, child) {
        // Globally reduce text scale so fonts fit smaller screens well
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(0.95),
          ),
          child: child!,
        );
      },
      home: const AuthGate(),
    );
  }
}



class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: FarmLoader(size: 80, color: Color(0xFF8B9467))));
        }
        if (snapshot.hasData) {
          return const MainScreen(); // Logged in
        }
        return const GetStartedScreen(); // Not logged in
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const WeatherScreen();
      case 2:
        return const ScannerScreen();
      case 3:
        return const SoilMoisturePredictorScreen();
      case 4:
        return const ShopScreen();
      case 5:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.currentLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: List.generate(6, (index) => _buildTab(index)),
          ),
          bottomNavigationBar: Container(
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F2EA),
              border: Border(
                top: BorderSide(
                  color: Color(0x33C9B6A3),
                ),
              ),
            ),
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBarItem(
              icon: Icons.home,
              label: TranslationService.translate('home'),
              isSelected: _selectedIndex == 0,
              onTap: () => setState(() => _selectedIndex = 0),
            ),
            _NavBarItem(
              icon: Icons.wb_sunny,
              label: TranslationService.translate('weather'),
              isSelected: _selectedIndex == 1,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            _NavBarScanItem(onTap: () => setState(() => _selectedIndex = 2)),
            _NavBarItem(
              icon: Icons.shower,
              label: 'Predict',
              isSelected: _selectedIndex == 3,
              onTap: () => setState(() => _selectedIndex = 3),
            ),
            _NavBarItem(
              icon: Icons.storefront,
              label: TranslationService.translate('shop'),
              isSelected: _selectedIndex == 4,
              onTap: () => setState(() => _selectedIndex = 4),
            ),
            _NavBarItem(
              icon: Icons.person,
              label: TranslationService.translate('profile'),
              isSelected: _selectedIndex == 5,
              onTap: () => setState(() => _selectedIndex = 5),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}



class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF8B9467) : const Color(0x993D3D3D),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF8B9467) : const Color(0x993D3D3D),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarScanItem extends StatelessWidget {
  final VoidCallback onTap;

  const _NavBarScanItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x338B9467), // earth-olive/20
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.center_focus_strong,
              color: Color(0xFF8B9467),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            TranslationService.translate('scan'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B9467),
            ),
          ),
        ],
      ),
    );
  }
}


