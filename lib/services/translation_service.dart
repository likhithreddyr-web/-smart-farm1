import 'package:flutter/material.dart';

class TranslationService {
  static final ValueNotifier<String> currentLanguage = ValueNotifier<String>('English');

  static const Map<String, Map<String, String>> _translations = {
    'English': {
      // Nav & Common
      'home': 'Home', 'weather': 'Weather', 'scan': 'Scan', 'shop': 'Shop', 'profile': 'Profile',
      'language_changed': 'Language changed to',
      
      // Shop
      'shop_title': 'Pesticide', 'tab_fungicide': 'FUNGICIDE', 'tab_insecticides': 'INSECTICIDES', 'tab_herbicide': 'HERBICIDE', 'tab_bio': 'BIO PESTICIDES', 'you_save': 'You save', 'added_to_cart': 'added to cart',

      // Home
      'current_weather': 'Current Weather', 'sunny_clear': 'Sunny, Clear Skies', 'no_rain_alert': 'No rain alert for today', 'moisture': 'MOISTURE', 'healthy_level': 'Healthy Level', 'scan_crop': 'Scan Crop', 'ai_analysis_desc': 'AI analysis for health\nand pests', 'sell_crops': 'Sell Crops', 'hire_machinery': 'Hire Machinery', 'check_prices': 'Check Market Prices',
      
      // Weather
      'weather_title': 'Weather Forecast', 'current_location': 'CURRENT LOCATION', 'humidity': 'HUMIDITY', 'wind': 'WIND', 'rainfall': 'RAINFALL', 'rainfall_warning': 'Rainfall Warning', 'soil_moisture_label': 'SOIL MOISTURE', 'uv_index': 'UV INDEX', 'air_quality': 'AIR QUALITY', 'next_5_days': 'Next 5 Days', 'see_full_report': 'See full report',
      
      // Scanner
      'point_at_leaf': 'POINT AT THE LEAF TO SCAN', 'ai_scanner': 'AI Scanner', 'analyzing_leaf': 'Analyzing leaf with AI...', 'click_to_scan': 'Click to Scan', 'import_from_gallery': 'Import from Gallery', 'analysis_result': 'Analysis Result', 'close': 'Close',

      // Profile
      'total_sales': 'Total Sales', 'major_crops': 'Major Crops', 'save_profile': 'Save Profile', 'edit_profile': 'Edit Profile', 'recent_sales': 'Recent Sales', 'view_all': 'View All', 'completed': 'COMPLETED', 'rental_history': 'Rental History', 'log_out': 'Log Out',
      'select_profile_picture': 'Select Profile Picture', 'full_name': 'Full Name', 'location': 'Location', 'e.g._wheat_rice': 'e.g. Wheat, Rice', 'profile_updated_successfully': 'Profile updated successfully!',
      'change_language': 'Change Language',

      // Shop
      'browse_categories': 'Browse Categories', 'machinery_booking': 'Machinery Booking', 'tools_booking': 'Tools Booking', 'seeds_booking': 'Seeds Booking', 'pesticides_booking': 'Pesticides Booking',

      // Rent / Sell
      'available_now': 'AVAILABLE NOW', 'professional_machinery': 'Professional Grade Machinery', 'all_equipment': 'All Equipment', 'tractors': 'Tractors', 'tillage': 'Tillage', 'per_hour': '/HOUR', 'book_now': 'Book Now', 'call_owner': 'Call Owner', 'booking_coming_soon': 'Booking flow coming soon!',
      'mandi_prices_title': 'Mandi Prices &\nMarketplace', 'mandi_prices_subtitle': 'Find the best rates for your harvest across\nregional markets.', 'nearby': 'Nearby', 'best_price': 'Best Price', 'verified': 'VERIFIED', 'per_quintal': 'PER QUINTAL', 'sell': 'Sell', 'market_analysis': 'Market Analysis', 'more_filters': 'More',
    },
    'हिंदी': {
      'home': 'होम', 'weather': 'मौसम', 'scan': 'स्कैन', 'shop': 'दुकान', 'profile': 'प्रोफ़ाइल',
      'language_changed': 'भाषा बदल कर हो गई है',
      'shop_title': 'कीटनाशक', 'tab_fungicide': 'कवकनाशी', 'tab_insecticides': 'कीटनाशकों', 'tab_herbicide': 'शाकनाशी', 'tab_bio': 'जैव कीटनाशक', 'you_save': 'आपकी बचत', 'added_to_cart': 'कार्ट में जोड़ा गया',
      
      'current_weather': 'वर्तमान मौसम', 'sunny_clear': 'साफ और धूप', 'no_rain_alert': 'आज बारिश की कोई चेतावनी नहीं', 'moisture': 'नमी', 'healthy_level': 'स्वस्थ स्तर', 'scan_crop': 'फसल स्कैन करें', 'ai_analysis_desc': 'स्वास्थ्य और कीटों का एआई विश्लेषण', 'sell_crops': 'फसलें बेचें', 'hire_machinery': 'मशीनरी किराए पर लें', 'check_prices': 'बाजार भाव जांचें',
      
      'weather_title': 'मौसम पूर्वानुमान', 'current_location': 'वर्तमान स्थान', 'humidity': 'नमी', 'wind': 'हवा', 'rainfall': 'वर्षा', 'rainfall_warning': 'वर्षा की चेतावनी', 'soil_moisture_label': 'मिट्टी की नमी', 'uv_index': 'यूवी सूचकांक', 'air_quality': 'वायु गुणवत्ता', 'next_5_days': 'अगले 5 दिन', 'see_full_report': 'पूरी रिपोर्ट देखें',
      
      'point_at_leaf': 'स्कैन करने के लिए पत्ती की ओर इशारा करें', 'ai_scanner': 'एआई स्कैनर', 'analyzing_leaf': 'एआई पत्ती का विश्लेषण कर रहा है...', 'click_to_scan': 'स्कैन करने के लिए क्लिक करें', 'import_from_gallery': 'गैलरी से आयात करें', 'analysis_result': 'विश्लेषण परिणाम', 'close': 'बंद करें',

      'total_sales': 'कुल बिक्री', 'major_crops': 'प्रमुख फसलें', 'save_profile': 'प्रोफ़ाइल सहेजें', 'edit_profile': 'प्रोफ़ाइल संपादित करें', 'recent_sales': 'हाल की बिक्री', 'view_all': 'सभी देखें', 'completed': 'पूर्ण', 'rental_history': 'किराये का इतिहास', 'log_out': 'लॉग आउट',
      'select_profile_picture': 'प्रोफ़ाइल चित्र चुनें', 'full_name': 'पूरा नाम', 'location': 'स्थान', 'e.g._wheat_rice': 'उदा. गेहूं, चावल', 'profile_updated_successfully': 'प्रोफ़ाइल सफलतापूर्वक अद्यतन की गई!',
      'change_language': 'भाषा बदलें',

      'browse_categories': 'श्रेणियाँ ब्राउज़ करें', 'machinery_booking': 'मशीनरी बुकिंग', 'tools_booking': 'उपकरण बुकिंग', 'seeds_booking': 'बीज बुकिंग', 'pesticides_booking': 'कीटनाशक बुकिंग',

      'available_now': 'अब उपलब्ध', 'professional_machinery': 'पेशेवर मशीनरी', 'all_equipment': 'सभी उपकरण', 'tractors': 'ट्रैक्टर', 'tillage': 'जुताई', 'per_hour': '/घंटा', 'book_now': 'अभी बुक करें', 'call_owner': 'मालिक को कॉल करें', 'booking_coming_soon': 'बुकिंग प्रवाह जल्द ही आ रहा है!',
      'mandi_prices_title': 'मंडी भाव और बाज़ार', 'mandi_prices_subtitle': 'क्षेत्रीय बाजारों में अपनी फसल के लिए सर्वोत्तम दरें खोजें।', 'nearby': 'आस-पास', 'best_price': 'सर्वोत्तम मूल्य', 'verified': 'सत्यापित', 'per_quintal': 'प्रति क्विंटल', 'sell': 'बेचें', 'market_analysis': 'बाज़ार विश्लेषण', 'more_filters': 'अधिक',
    },
    'ಕನ್ನಡ': {
      'home': 'ಮುಖಪುಟ', 'weather': 'ಹವಾಮಾನ', 'scan': 'ಸ್ಕ್ಯಾನ್', 'shop': 'ಅಂಗಡಿ', 'profile': 'ಪ್ರೊಫೈಲ್',
      'language_changed': 'ಭಾಷೆ ಬದಲಾಯಿಸಲಾಗಿದೆ',
      'shop_title': 'ಕೀಟನಾಶಕ', 'tab_fungicide': 'ಶಿಲೀಂಧ್ರನಾಶಕ', 'tab_insecticides': 'ಕೀಟನಾಶಕಗಳು', 'tab_herbicide': 'ಕಳೆನಾಶಕ', 'tab_bio': 'ಜೈವಿಕ ಕೀಟನಾಶಕಗಳು', 'you_save': 'ನೀವು ಉಳಿಸುತ್ತೀರಿ', 'added_to_cart': 'ಕಾರ್ಟ್‌ಗೆ ಸೇರಿಸಲಾಗಿದೆ',
      
      'current_weather': 'ಪ್ರಸ್ತುತ ಹವಾಮಾನ', 'sunny_clear': 'ಬಿಸಿಲು ಮತ್ತು ಸ್ಪಷ್ಟ', 'no_rain_alert': 'ಇಂದು ಮಳೆಯ ಎಚ್ಚರಿಕೆ ಇಲ್ಲ', 'moisture': 'ತೇವಾಂಶ', 'healthy_level': 'ಆರೋಗ್ಯಕರ ಮಟ್ಟ', 'scan_crop': 'ಬೆಳೆಯನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಿ', 'ai_analysis_desc': 'ಆರೋಗ್ಯ ಮತ್ತು ಕೀಟಗಳ AI ವಿಶ್ಲೇಷಣೆ', 'sell_crops': 'ಬೆಳೆಗಳನ್ನು ಮಾರಿ', 'hire_machinery': 'ಯಂತ್ರೋಪಕರಣಗಳನ್ನು ಬಾಡಿಗೆಗೆ ಪಡೆಯಿರಿ', 'check_prices': 'ಮಾರುಕಟ್ಟೆ ಬೆಲೆಗಳನ್ನು ಹತ್ತಿರ',
      
      'weather_title': 'ಹವಾಮಾನ ಮುನ್ಸೂಚನೆ', 'current_location': 'ಪ್ರಸ್ತುತ ಸ್ಥಳ', 'humidity': 'ಆರ್ದ್ರತೆ', 'wind': 'ಗಾಳಿ', 'rainfall': 'ಮಳೆ', 'rainfall_warning': 'ಮಳೆಯ ಎಚ್ಚರಿಕೆ', 'soil_moisture_label': 'ಮಣ್ಣಿನ ತೇವಾಂಶ', 'uv_index': 'ಯುವಿ ಸೂಚಿ', 'air_quality': 'ವಾಯು ಗುಣಮಟ್ಟ', 'next_5_days': 'ಮುಂದಿನ 5 ದಿನಗಳು', 'see_full_report': 'ಸಂಪೂರ್ಣ ವರದಿ ನೋಡಿ',
      
      'point_at_leaf': 'ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ಎಲೆಯ ಕಡೆಗೆ ಪಾಯಿಂಟ್ ಮಾಡಿ', 'ai_scanner': 'AI ಸ್ಕ್ಯಾನರ್', 'analyzing_leaf': 'AI ನಿಂದ ಎಲೆ ವಿಶ್ಲೇಷಿಸಲಾಗುತ್ತಿದೆ...', 'click_to_scan': 'ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ಕ್ಲಿಕ್ ಮಾಡಿ', 'import_from_gallery': 'ಗ್ಯಾಲರಿಯಿಂದ ಆಮದು ಮಾಡಿ', 'analysis_result': 'ವಿಶ್ಲೇಷಣೆ ಫಲಿತಾಂಶ', 'close': 'ಮುಚ್ಚಿ',

      'total_sales': 'ಒಟ್ಟು ಮಾರಾಟ', 'major_crops': 'ಪ್ರಮುಖ ಬೆಳೆಗಳು', 'save_profile': 'ಪ್ರೊಫೈಲ್ ಉಳಿಸಿ', 'edit_profile': 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ', 'recent_sales': 'ಇತ್ತೀಚಿನ ಮಾರಾಟಗಳು', 'view_all': 'ಎಲ್ಲವನ್ನೂ ವೀಕ್ಷಿಸಿ', 'completed': 'ಪೂರ್ಣಗೊಂಡಿದೆ', 'rental_history': 'ಬಾಡಿಗೆ ಇತಿಹಾಸ', 'log_out': 'ಲಾಗ್ ಔಟ್',
      'select_profile_picture': 'ಪ್ರೊಫೈಲ್ ಚಿತ್ರವನ್ನು ಆಯ್ಕೆಮಾಡಿ', 'full_name': 'ಪೂರ್ಣ ಹೆಸರು', 'location': 'ಸ್ಥಳ', 'e.g._wheat_rice': 'ಉದಾ. ಗೋಧಿ, ಅಕ್ಕಿ', 'profile_updated_successfully': 'ಪ್ರೊಫೈಲ್ ಅನ್ನು ಯಶಸ್ವಿಯಾಗಿ ನವೀಕರಿಸಲಾಗಿದೆ!',
      'change_language': 'ಭಾಷೆ ಬದಲಾಯಿಸಿ',

      'browse_categories': 'ವರ್ಗಗಳನ್ನು ಬ್ರೌಸ್ ಮಾಡಿ', 'machinery_booking': 'ಯಂತ್ರೋಪಕರಣಗಳ ಬುಕಿಂಗ್', 'tools_booking': 'ಪರಿಕರಗಳ ಬುಕಿಂಗ್', 'seeds_booking': 'ಬೀಜಗಳ ಬುಕಿಂಗ್', 'pesticides_booking': 'ಕೀಟನಾಶಕಗಳ ಬುಕಿಂಗ್',

      'available_now': 'ಈಗ ಲಭ್ಯವಿದೆ', 'professional_machinery': 'ವೃತ್ತಿಪರ ಯಂತ್ರೋಪಕರಣಗಳು', 'all_equipment': 'ಎಲ್ಲಾ ಉಪಕರಣಗಳು', 'tractors': 'ಟ್ರಾಕ್ಟರುಗಳು', 'tillage': 'ಉಳುಮೆ', 'per_hour': '/ಗಂಟೆ', 'book_now': 'ಈಗ ಬುಕ್ ಮಾಡಿ', 'call_owner': 'ಮಾಲೀಕರಿಗೆ ಕರೆ ಮಾಡಿ', 'booking_coming_soon': 'ಬುಕಿಂಗ್ ಹರಿವು ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ!',
      'mandi_prices_title': 'ಮಾರುಕಟ್ಟೆ ಬೆಲೆಗಳು ಮತ್ತು ಮಾರುಕಟ್ಟೆ', 'mandi_prices_subtitle': 'ನಿಮ್ಮ ಫಸಲಿಗೆ ಉತ್ತಮ ದರಗಳನ್ನು ಹುಡುಕಿ.', 'nearby': 'ಹತ್ತಿರದ', 'best_price': 'ಉತ್ತಮ ಬೆಲೆ', 'verified': 'ಪರಿಶೀಲಿಸಲಾಗಿದೆ', 'per_quintal': 'ಪ್ರತಿ ಕ್ವಿಂಟಾಲ್\u200cಗೆ', 'sell': 'ಮಾರು', 'market_analysis': 'ಮಾರುಕಟ್ಟೆ ವಿಶ್ಲೇಷಣೆ', 'more_filters': 'ಇನ್ನಷ್ಟು',
    },
  };

  static String translate(String key) {
    final lang = currentLanguage.value;
    if (_translations.containsKey(lang) && _translations[lang]!.containsKey(key)) {
      return _translations[lang]![key]!;
    }
    // Fallback to English if language or key not found
    return _translations['English']?[key] ?? key;
  }
}
