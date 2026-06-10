import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../providers/app_state.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onBack;
  final Map<String, dynamic>? currentUser;

  const ProfilePage({
    super.key,
    required this.onBack,
    this.currentUser,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _apiService = ApiService();

  bool _loading = true;
  bool _saving = false;
  String _gender = 'male';
  File? _selectedImage;
  String? _avatarUrl;
  String? _message;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with available data for instant feedback
    if (widget.currentUser != null) {
      _nameController.text = widget.currentUser?['user_metadata']?['name'] ?? '';
      _emailController.text = widget.currentUser?['email'] ?? '';
      _avatarUrl = widget.currentUser?['avatar_url'];
    }
    
    // update BMI when height or weight changes
    void updateState() {
      if (mounted) setState(() {});
    }
    _heightController.addListener(updateState);
    _weightController.addListener(updateState);

    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final profile = await _apiService.getProfile();
      if (mounted) {
        // Only update if text is effectively empty or default to avoid wiping user edits if they started typing fast
        // But since we disable fields during load, direct update is safe.
        _nameController.text = profile['name'] ?? widget.currentUser?['user_metadata']?['name'] ?? '';
        _emailController.text = profile['email'] ?? widget.currentUser?['email'] ?? '';
        _ageController.text = profile['age']?.toString() ?? '28';
        _heightController.text = profile['height']?.toString() ?? '175';
        _weightController.text = profile['weight']?.toString() ?? '70';
        _gender = profile['gender'] ?? 'male';
        
        // Update avatar url
        if (profile['avatar_url'] != null) {
          setState(() {
            _avatarUrl = profile['avatar_url'];
          });
        }
      }
    } catch (e) {
      // Keep pre-filled data or defaults
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        
        // Auto-upload when selected
        await _uploadImage();
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      setState(() => _saving = true);
      
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.updateAvatar(_selectedImage!);
      
      // Update local URL to show the new one
      final profile = await _apiService.getProfile(); // Refresh to get the generic URL
      
      setState(() {
        _message = 'Profile photo updated! 📸';
        _isSuccess = true;
        if (profile['avatar_url'] != null) {
          _avatarUrl = profile['avatar_url'];
          _selectedImage = null; // Clear local file to use network url
        }
      });
      
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _message = null);
      });
      
    } catch (e) {
      setState(() {
        _message = 'Failed to upload photo: $e';
        _isSuccess = false;
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _message = null;
    });

    try {
      await _apiService.saveProfile({
        'name': _nameController.text,
        // Email is managed by Auth, not stored in profile table
        'age': int.tryParse(_ageController.text) ?? 28,
        'height': int.tryParse(_heightController.text) ?? 175,
        'weight': double.tryParse(_weightController.text) ?? 70.0,
        'gender': _gender,
      });

      setState(() {
        _message = 'Profile updated successfully! 🎉';
        _isSuccess = true;
        _saving = false;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _message = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to save profile. Please try again.';
        _isSuccess = false;
        _saving = false;
      });
    }
  }

  double _calculateBMI() {
    final height = double.tryParse(_heightController.text) ?? 175;
    final weight = double.tryParse(_weightController.text) ?? 70;
    if (height > 0) {
      return weight / ((height / 100) * (height / 100));
    }
    return 0;
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {


    final bmi = _calculateBMI();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Profile Information',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: _loading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(
                  backgroundColor: Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6)),
                ),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: (_selectedImage == null && _avatarUrl == null)
                                  ? const LinearGradient(
                                      colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                                    )
                                  : null,
                              image: _selectedImage != null
                                  ? DecorationImage(
                                      image: FileImage(_selectedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : (_avatarUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(_avatarUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: (_selectedImage == null && _avatarUrl == null)
                                ? const Icon(Icons.person, color: Colors.white, size: 50)
                                : null,
                          ),
                        ),
                        if (_saving)
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black26,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF14B8A6),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text(
                        'Change Photo',
                        style: TextStyle(
                          color: Color(0xFF14B8A6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Basic Information
              const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 32),

              // Physical Stats
              const Text(
                'Physical Stats',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              // Gender
              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _gender = 'male'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _gender == 'male'
                              ? const Color(0xFFF0FDFA)
                              : Colors.white,
                          border: Border.all(
                            color: _gender == 'male'
                                ? const Color(0xFF14B8A6)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Male',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _gender = 'female'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _gender == 'female'
                              ? const Color(0xFFF0FDFA)
                              : Colors.white,
                          border: Border.all(
                            color: _gender == 'female'
                                ? const Color(0xFF14B8A6)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Female',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _heightController,
                label: 'Height (cm)',
                icon: Icons.straighten,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _weightController,
                label: 'Current Weight (kg)',
                icon: Icons.monitor_weight,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 24),

              // BMI Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Body Mass Index',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              bmi.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'BMI',
                              style: TextStyle(color: Colors.grey[500], fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getBMICategory(bmi),
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.straighten,
                        color: Color(0xFF14B8A6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF14B8A6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              if (_message != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isSuccess
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isSuccess
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                    ),
                  ),
                  child: Text(
                    _message!,
                    style: TextStyle(
                      color: _isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF14B8A6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
