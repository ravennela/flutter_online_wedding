import 'package:flutter/material.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedCity;
  final List<String> _selectedExperiences = [];
  bool _isProcessing = false;

  final List<String> _cities = ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai', 'Pune'];
  final List<String> _experienceTypes = [
    'Gala Events',
    'Exhibitions',
    'Private Viewing',
    'Art Auctions',
    'Wine Tasting',
    'Concierge Travel',
    'Boutique Events',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onExperienceTap(String type) {
    setState(() {
      if (_selectedExperiences.contains(type)) {
        _selectedExperiences.remove(type);
      } else {
        _selectedExperiences.add(type);
      }
    });
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Complete Profile',
          style: AppTextStyles.headingM.copyWith(
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTitleSection(),
                    const SizedBox(height: 40),
                    _buildProfileImagePicker(),
                    const SizedBox(height: 48),
                    _buildInputLabel('FULL NAME'),
                    _buildNameField(),
                    const SizedBox(height: 24),
                    _buildInputLabel('EMAIL ADDRESS'),
                    _buildEmailField(),
                    const SizedBox(height: 8),
                    Text(
                      'Optional: For receiving curated event invitations.',
                      style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    _buildInputLabel('PRIMARY CITY'),
                    _buildCityDropdown(),
                    const SizedBox(height: 32),
                    _buildInputLabel('PREFERRED EXPERIENCE TYPES'),
                    const SizedBox(height: 12),
                    _buildExperienceChips(),
                    const SizedBox(height: 48),
                    _buildActionButton(),
                    const SizedBox(height: 16),
                    const Text(
                      'STEP 1 OF 3',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Personalize Your Journey',
          textAlign: TextAlign.center,
          style: AppTextStyles.headingXL.copyWith(
            fontFamily: 'Serif',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Help us personalize your experience with tailored curations.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyM.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 64,
              color: Color(0xFFCBD5E1),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF92400E), // Golden brown
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: _inputDecoration('E.g. Alexander Sterling'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Full name is required';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration('name@atelier.com'),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          hint: Text('Select your location', style: TextStyle(color: Colors.grey[400])),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
          items: _cities.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Text(city),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCity = value),
        ),
      ),
    );
  }

  Widget _buildExperienceChips() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _experienceTypes.map((type) {
        final isSelected = _selectedExperiences.contains(type);
        return GestureDetector(
          onTap: () => _onExperienceTap(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFED7AA) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? const Color(0xFFF97316).withOpacity(0.5) : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? const Color(0xFF9A3412) : const Color(0xFF475569),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check, size: 14, color: Color(0xFF9A3412)),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A), // Premium Black
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: _isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Saving Preferences...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : const Text(
                'Complete Profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
    );
  }
}
