
import 'dart:js' as js;

void openRazorpayCheckout(Map<String, dynamic> options) {
  js.context.callMethod('openRazorpayCheckout', [options]);
}