import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AiScannerService {
  // Use your own API key, ideally loaded from secure config or environment.
  static final String _apiKey = 'AIzaSyDvsVYKn0tQ3zpQSlAvTOWIcY9Dk7w8Z5o';

  late final GenerativeModel _model;

  AiScannerService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> analyzeLeaf(File imageFile) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_API_KEY') {
      return 'AI API key is missing. Please add your API key in AiScannerService.';
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final prompt = TextPart(
        'Analyze this image of a plant leaf and explain whether it is healthy or has a disease/pest/nutrient issue. '
        'If there is an issue, name the likely cause and suggest simple treatment steps in clearly readable format.',
      );

      final response = await _model.generateContent([
        Content.multi([
          prompt,
          DataPart('image/jpeg', bytes),
        ]),
      ]).timeout(const Duration(seconds: 45));

      if (response.text == null || response.text!.trim().isEmpty) {
        return 'AI returned no analysis. Please check your API key and network connectivity.';
      }
      return response.text!;
    } catch (e) {
      debugPrint('Error analyzing leaf: $e');
      return 'AI analyzer error: ${e.toString()}';
    }
  }
}
