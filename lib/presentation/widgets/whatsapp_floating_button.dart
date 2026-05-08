import 'package:flutter/material.dart';
import '../../core/constants/whatsapp_constants.dart';
import '../../core/services/whatsapp_service.dart';

/// A modern, responsive floating action button that opens WhatsApp.
/// Works smoothly across Android, iOS, and Web environments.
/// 
/// Note: To use this widget, wrap it in an overarching Stack or
/// put it in the floatingActionButton slot of a Scaffold.
/// For raw positioning on the bottom right of any screen,
/// just drop this widget inside a Stack.
class WhatsAppFloatingButton extends StatefulWidget {
  const WhatsAppFloatingButton({super.key});

  @override
  State<WhatsAppFloatingButton> createState() => _WhatsAppFloatingButtonState();
}

class _WhatsAppFloatingButtonState extends State<WhatsAppFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  // Track hover state for Flutter Web
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // Setup smooth elastic entrance animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    // Trigger entrance animation slightly after mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _animationController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Triggered when the user taps or clicks the WhatsApp button.
  Future<void> _handleWhatsAppLaunch(BuildContext context) async {
    // Add a quick feedback animation on tap
    await _animationController.reverse(from: 0.8);
    if (mounted) _animationController.forward();

    // Call our clean architecture service
    final success = await WhatsAppService.instance.openWhatsApp(
      phoneNumber: WhatsAppConstants.adminNumber,
      message: WhatsAppConstants.defaultMessage,
    );

    // If WhatsApp failed to open (e.g. app not installed, permissions, etc.)
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  WhatsAppConstants.errorMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // The widget returns a Positioned block. To use this effectively,
    // place this widget directly inside a Stack.
    return Positioned(
      bottom: 24.0,
      right: 24.0,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Tooltip(
          // Tooltip natively supported by Material 3
          message: WhatsAppConstants.tooltipMessage,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            color: Colors.white, 
            fontSize: 12, 
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: MouseRegion(
            // Handles Web / Desktop hover events
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: () => _handleWhatsAppLaunch(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                // Grow slightly on hover for Web
                transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Smooth material design shadow effect
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25D366).withOpacity(_isHovered ? 0.6 : 0.3),
                      blurRadius: _isHovered ? 20 : 12,
                      offset: const Offset(0, 6),
                      spreadRadius: _isHovered ? 4 : 0,
                    ),
                  ],
                ),
                // Core WhatsApp icon using standard Material conventions
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF25D366), // Official WhatsApp Green
                  ),
                  child: const Center(
                    child: Icon(
                      // Using a fallback chat icon since there is no native WhatsApp icon
                      // in the standard Flutter Material icons.
                      Icons.chat_bubble_rounded, 
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
