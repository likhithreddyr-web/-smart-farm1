import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_farm/screens/notifications_screen.dart';
import 'package:smart_farm/screens/login_screen.dart';
import 'package:smart_farm/screens/orders_screen.dart';
import 'package:smart_farm/widgets/farm_loader.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  String _name = '';
  String _location = '';
  String _majorCrops = '';
  String _phone = '';
  String _profileImageUrl = '';

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _cropsController = TextEditingController();
  final _phoneController = TextEditingController();

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _cropsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (_uid.isEmpty) { setState(() => _isLoading = false); return; }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _name = data['name'] ?? '';
        _location = data['location'] ?? '';
        _majorCrops = data['majorCrops'] ?? '';
        _phone = data['phone'] ?? '';
        _profileImageUrl = data['profileImageUrl'] ?? '';
      }
    } catch (_) {}
    _nameController.text = _name;
    _locationController.text = _location;
    _cropsController.text = _majorCrops;
    _phoneController.text = _phone;
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (_uid.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      // Direct Firestore save using the base64 formatted string
      await FirebaseFirestore.instance.collection('users').doc(_uid).set({
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim(),
        'majorCrops': _cropsController.text.trim(),
        'phone': _phoneController.text.trim(),
        'profileImageUrl': _profileImageUrl,
      }, SetOptions(merge: true));
      
      setState(() {
        _name = _nameController.text.trim();
        _location = _locationController.text.trim();
        _majorCrops = _cropsController.text.trim();
        _phone = _phoneController.text.trim();
        _isEditing = false;
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85, // Balanced compression for much better visual quality while keeping base64 size safe
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      setState(() => _profileImageUrl = 'base64:$base64String');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Color(0xFFF6FAF2), body: Center(child: FarmLoader(size: 80, color: Color(0xFF2E7D32))));

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          // Green banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: _profileImageUrl.isEmpty
                            ? null
                            : (_profileImageUrl.startsWith('http')
                                ? NetworkImage(_profileImageUrl)
                                : _profileImageUrl.startsWith('base64:')
                                    ? MemoryImage(base64Decode(_profileImageUrl.substring(7))) as ImageProvider
                                    : FileImage(File(_profileImageUrl)) as ImageProvider),
                        child: _profileImageUrl.isEmpty
                            ? const Icon(Icons.person, size: 48, color: Color(0xFF2E7D32))
                            : null,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 14, color: Color(0xFF2E7D32)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _name.isEmpty ? 'Welcome!' : 'Welcome, $_name',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _location.isEmpty ? 'No location set' : _location,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Details card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildField(Icons.person, 'Name', _nameController, _isEditing),
                        const Divider(height: 24),
                        _buildField(Icons.location_on, 'Address / Location', _locationController, _isEditing),
                        const Divider(height: 24),
                        _buildField(Icons.grass, 'Major Crops', _cropsController, _isEditing),
                        const Divider(height: 24),
                        _buildField(Icons.phone, 'Phone', _phoneController, _isEditing),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _isSaving ? null : () {
                        if (_isEditing) {
                          _saveProfile();
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                      icon: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: FarmLoader.small())
                          : Icon(_isEditing ? Icons.save : Icons.edit),
                      label: Text(_isEditing ? 'Save Profile' : 'Edit Profile',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => OrdersScreen()),
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('My Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(IconData icon, String label, TextEditingController controller, bool editing) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: editing
              ? TextField(
                  controller: controller,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: label,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    border: InputBorder.none,
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF2E7D32))),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(
                      controller.text.isEmpty ? 'Not set' : controller.text,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: controller.text.isEmpty ? Colors.grey : Colors.black87),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
