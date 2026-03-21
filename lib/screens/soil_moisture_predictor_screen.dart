import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smart_farm/widgets/farm_loader.dart';

class SoilMoisturePredictorScreen extends StatefulWidget {
  const SoilMoisturePredictorScreen({super.key});

  @override
  State<SoilMoisturePredictorScreen> createState() => _SoilMoisturePredictorScreenState();
}

class _SoilMoisturePredictorScreenState extends State<SoilMoisturePredictorScreen> {
  final _temperatureController = TextEditingController();
  final _humidityController = TextEditingController();
  final _rainfallController = TextEditingController();
  final _locationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  XFile? _pickedImage;
  String _soilType = 'Loamy';
  final List<String> _soilTypes = ['Loamy', 'Clay', 'Sandy', 'Silty', 'Peaty', 'Saline'];
  
  bool _isLoading = false;
  String _predictedLabel = '';
  double _predictedPercent = 0.0;
  String _recommendation = '';

  @override
  void dispose() {
    _temperatureController.dispose();
    _humidityController.dispose();
    _rainfallController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 1080);
      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not pick image.')));
    }
  }

  Future<void> _captureImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70, maxWidth: 1080);
      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not capture image.')));
    }
  }

  void _simulatePrediction() {
    if (_isLoading) return;

    final temp = double.tryParse(_temperatureController.text) ?? 28;
    final humidity = double.tryParse(_humidityController.text) ?? 55;
    final rainfall = double.tryParse(_rainfallController.text) ?? 5;

    setState(() {
      _isLoading = true;
      _predictedLabel = '';
      _recommendation = '';
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      double score = humidity * 0.45 + rainfall * 0.35 - temp * 0.25;
      score += _soilType == 'Clay' ? 6 : _soilType == 'Sandy' ? -5 : 0;
      score = score.clamp(8, 95);

      final pct = score.toInt();
      String label;
      String rec;
      Color color;

      if (pct < 40) {
        label = 'Low';
        rec = 'Irrigation needed. Add water and mulch to retain moisture.';
        color = Colors.red.shade600;
      } else if (pct < 70) {
        label = 'Medium';
        rec = 'Maintain current condition. Continue regular monitoring.';
        color = Colors.orange.shade700;
      } else {
        label = 'High';
        rec = 'Avoid watering now and let soil drain to prevent waterlogging.';
        color = Colors.green.shade700;
      }

      setState(() {
        _predictedPercent = pct.toDouble();
        _predictedLabel = label;
        _recommendation = rec;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Soil moisture estimated as $label (${pct}%).'),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  Widget _buildInputField({required String label, required TextEditingController controller, String suffixText = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2F2F2F))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              suffixText: suffixText,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Soil Moisture Predictor'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECF5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDDE8DA)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFEACC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.grass, color: Color(0xFF3A5D2C), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Check your soil condition instantly', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Enter data and get quick moisture status with recommendations.', style: TextStyle(fontSize: 13, color: Color(0xFF5D5D5D))),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Text('Input Data', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Icon(Icons.photo_camera, color: Color(0xFF406527)),
                              SizedBox(width: 10),
                              Expanded(child: Text('Upload / Capture Soil Image', style: TextStyle(fontWeight: FontWeight.w600))),
                              Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF707070)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_pickedImage != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                        child: Image.file(
                          File(_pickedImage!.path),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: const Center(
                          child: Text('No image selected yet. Use Upload to add a soil sample image.', style: TextStyle(color: Color(0xFF5A5A5A))),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF4C7A2B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          hintText: 'Enter location (e.g., Bengaluru)',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3F7A2F),
                        side: const BorderSide(color: Color(0xFF3F7A2F)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        setState(() {
                          _locationController.text = 'Bengaluru, KA';
                        });
                      },
                      child: const Text('Auto-detect'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildInputField(label: 'Temperature (°C)', controller: _temperatureController, suffixText: '°C')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInputField(label: 'Humidity (%)', controller: _humidityController, suffixText: '%')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildInputField(label: 'Rainfall (mm)', controller: _rainfallController, suffixText: 'mm')),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Soil Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2F2F2F))),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<String>(
                            value: _soilType,
                            borderRadius: BorderRadius.circular(12),
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            items: _soilTypes.map((soil) => DropdownMenuItem(value: soil, child: Text(soil))).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _soilType = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: _isLoading ? const SizedBox(width: 20, height: 20, child: FarmLoader.small()) : const Icon(Icons.water_drop, color: Colors.white),
                  label: Text(_isLoading ? 'Checking...' : 'Check Moisture', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _simulatePrediction,
                ),
              ),

              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD8DECE)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Result', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.thermostat, color: Color(0xFF3A6A2F)),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Soil Moisture Level', style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(_predictedLabel.isEmpty ? 'Unknown' : _predictedLabel, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          backgroundColor: _predictedLabel == 'High'
                              ? Colors.green.shade600
                              : _predictedLabel == 'Medium'
                                  ? Colors.orange.shade600
                                  : _predictedLabel == 'Low'
                                      ? Colors.red.shade600
                                      : Colors.grey.shade500,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _predictedLabel.isEmpty ? 'No prediction yet' : 'Estimated Moisture: ${_predictedPercent.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D)),
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFE8E8E8)),
                    const SizedBox(height: 10),
                    const Text('Recommendation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      _recommendation.isEmpty
                          ? 'Use the button above to compute soil moisture and get simple advice.'
                          : _recommendation,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF424242)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF0D7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Color(0xFF2B5325)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: For more accurate results, enter current field values and use the soil image preview as reference.',
                        style: TextStyle(color: Color(0xFF2F4F31), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
