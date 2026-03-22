import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'package:smart_farm/services/ai_scanner_service.dart';
import 'package:smart_farm/screens/scan_history_screen.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/widgets/farm_loader.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final AiScannerService _aiService = AiScannerService();
  bool _isScanning = false;

  Future<void> _scanImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _isScanning = true;
      });

      final File imageFile = File(image.path);

      // Analyze with Gemini
      final result = await _aiService.analyzeLeaf(imageFile);

      // Save to history (don't block UI waiting for Firestore)
      _saveScanHistory(imageFile, result);

      if (mounted) {
        _showResultDialog(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _saveScanHistory(File imageFile, String result) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final scanId = const Uuid().v4();
      final now = DateTime.now();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .doc(scanId)
          .set({
        'id': scanId,
        'result': result,
        'imagePath': imageFile.path,
        'scannedAt': now,
        'source': 'mobile',
      });
    } catch (e) {
      debugPrint('Failed to save to history: $e');
    }
  }

  void _showResultDialog(String result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(TranslationService.translate('analysis_result'), 
          style: TextStyle(color: isDark ? Theme.of(context).primaryColor : const Color(0xFF8B9467))),
        content: SingleChildScrollView(
          child: Text(result, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TranslationService.translate('close'), 
              style: TextStyle(color: isDark ? Colors.redAccent : const Color(0xFFD97757))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.currentLanguage,
      builder: (context, lang, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final headerColor = isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFF5F2EA);
        final accentColor = isDark ? Theme.of(context).primaryColor : const Color(0xFF8B9467);
        final textColor = Theme.of(context).textTheme.bodyLarge?.color;

        return SafeArea(
          child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: headerColor,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : const Color(0x4DC9B6A3),
                ),
              ),
            ),
            child: Text(TranslationService.translate('point_at_leaf'), 
              textAlign: TextAlign.center, 
              style: TextStyle(color: isDark ? Colors.white60 : const Color(0xCC3D3D3D), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.2)),
          ),
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: headerColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.agriculture, color: accentColor),
                    const SizedBox(width: 12),
                    Text(TranslationService.translate('ai_scanner'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.history, color: accentColor),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanHistoryScreen()));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF27492A), // Dark agricultural green
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          children: [
                            CustomPaint(
                              size: Size.infinite,
                              painter: OverlayPainter(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isScanning)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FarmLoader(size: 60, color: accentColor),
                          const SizedBox(height: 16),
                          Text(TranslationService.translate('analyzing_leaf'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                if (!_isScanning)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.only(top: 32, bottom: 48, left: 24, right: 24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0x993D3D3D), // earth-dark/60
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97757),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.2), width: 4),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8))],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => _scanImage(ImageSource.camera),
                                child: const Center(
                                  child: Icon(Icons.photo_camera, color: Colors.white, size: 36),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(TranslationService.translate('click_to_scan'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))])),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () => _scanImage(ImageSource.gallery),
                            icon: const Icon(Icons.upload_file, color: Color(0xFFC9B6A3)),
                            label: Text(TranslationService.translate('import_from_gallery'), style: const TextStyle(color: Color(0xFFC9B6A3), fontSize: 16, fontWeight: FontWeight.w500, decoration: TextDecoration.underline, decorationColor: Color(0xFFC9B6A3))),
                            style: TextButton.styleFrom(foregroundColor: const Color(0xFFF5F2EA)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
        );
      },
    );
  }
}

class OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outerRect = Rect.fromLTWH(-2000, -2000, 4000, 4000);
    final innerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    final path = Path()
      ..addRect(outerRect)
      ..addRRect(RRect.fromRectAndRadius(innerRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    final paint = Paint()
      ..color = const Color(0x663D3D3D)
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
