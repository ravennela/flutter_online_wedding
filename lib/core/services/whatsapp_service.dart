import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// A reusable service to handle WhatsApp launching across different platforms.
class WhatsAppService {
  // Private constructor for singleton pattern
  WhatsAppService._();
  
  // Singleton instance
  static final WhatsAppService instance = WhatsAppService._();

  /// Opens WhatsApp chat with the provided [phoneNumber] and [message].
  /// Returns [true] if successfully launched, [false] otherwise.
  Future<bool> openWhatsApp({
    required String phoneNumber,
    required String message,
  }) async {
    // Format the phone number (remove +, spaces, hyphens, etc.)
    final formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // URL encode the message
    final encodedMessage = Uri.encodeComponent(message);
    
    // Create the WhatsApp URL
    // The https://wa.me/ format works on Web, Android, and iOS natively and handles fallback
    final uri = Uri.parse('https://wa.me/$formattedNumber?text=$encodedMessage');

    try {
      // Check if we can launch the URL
      if (await canLaunchUrl(uri)) {
        // Launch as an external application (forces native app if installed on mobile)
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('Could not launch WhatsApp URI: $uri');
        return false;
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      return false;
    }
  }
}
