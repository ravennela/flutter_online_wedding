class WhatsAppConstants {
  // Prevent instantiation
  WhatsAppConstants._();

  /// Admin WhatsApp number in E.164 format (without +) or raw format
  /// The wa.me format expects the number with country code but without '+'
  static const String adminNumber = '919133148638'; 
  
  /// Prefilled message to send to the admin
  static const String defaultMessage = 'Hello, I need support';
  
  /// Custom tooltips for web and desktop users
  static const String tooltipMessage = 'Chat with us on WhatsApp';
  
  /// Error message shown in Snackbar if WhatsApp cannot be launched
  static const String errorMessage = 'Could not open WhatsApp. Please check if it is installed.';
}
