import 'package:flutter/material.dart';
import 'package:smart_farm/widgets/farm_loader.dart';

class MachineryBookingScreen extends StatefulWidget {
  final String machineName;
  const MachineryBookingScreen({super.key, required this.machineName});

  @override
  State<MachineryBookingScreen> createState() => _MachineryBookingScreenState();
}

class _MachineryBookingScreenState extends State<MachineryBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _hoursController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF2E7D32))),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a booking date.')));
      return;
    }
    setState(() => _isSubmitting = true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSubmitting = false);

    if (!mounted) return;
    // Navigate to confirmation screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _BookingConfirmationScreen(
          machineName: widget.machineName,
          userName: _nameController.text.trim(),
          date: _selectedDate!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Book ${widget.machineName}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Machine chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.agriculture, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 10),
                    Text('Booking: ${widget.machineName}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), fontSize: 15)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Your Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),

              _buildFormCard([
                _field(_nameController, 'Full Name', Icons.person, validator: (v) => v!.isEmpty ? 'Enter your name' : null),
                const SizedBox(height: 14),
                _field(_phoneController, 'Mobile Number', Icons.phone,
                    keyboard: TextInputType.phone,
                    validator: (v) => v!.length < 10 ? 'Enter valid mobile number' : null),
                const SizedBox(height: 14),
                _field(_addressController, 'Farm Address', Icons.location_on,
                    maxLines: 3, validator: (v) => v!.isEmpty ? 'Enter your address' : null),
                const SizedBox(height: 14),
                _field(_hoursController, 'Number of Hours Required', Icons.timer,
                    keyboard: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Enter hours needed' : null),
              ]),

              const SizedBox(height: 16),
              const Text('Booking Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _selectedDate == null ? Colors.grey.shade300 : const Color(0xFF2E7D32)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Tap to select date'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: _selectedDate != null ? FontWeight.bold : FontWeight.normal,
                          color: _selectedDate != null ? Colors.black87 : Colors.black45,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isSubmitting ? null : _submitBooking,
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: FarmLoader.small())
                      : const Icon(Icons.check_circle_outline),
                  label: const Text('Submit Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboard, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        filled: true,
        fillColor: const Color(0xFFF6FAF2),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

// ─── Confirmation Screen ───────────────────────────────────────────────────────

class _BookingConfirmationScreen extends StatelessWidget {
  final String machineName;
  final String userName;
  final DateTime date;

  const _BookingConfirmationScreen({
    required this.machineName,
    required this.userName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF2),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success animation
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2E7D32), width: 3),
                  ),
                  child: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 70),
                ),
                const SizedBox(height: 28),
                const Text('Booking Confirmed!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                const SizedBox(height: 12),
                const Text(
                  'Machinery booked successfully.\nIt will reach your farm soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
                ),
                const SizedBox(height: 24),
                // Booking summary card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      _row(Icons.agriculture, 'Machine', machineName),
                      const Divider(height: 20),
                      _row(Icons.person, 'Name', userName),
                      const Divider(height: 20),
                      _row(Icons.calendar_today, 'Date', '${date.day}/${date.month}/${date.year}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Simulated notification
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFCC02)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.notifications_active, color: Color(0xFFF57F17)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'SMS Sent: "Your machinery booking is confirmed and is on the way."',
                          style: TextStyle(fontSize: 12, color: Color(0xFF795548)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Text('Back to Shop', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 18),
        const SizedBox(width: 10),
        Text('$label:', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
