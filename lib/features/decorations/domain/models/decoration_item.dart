import 'package:flutter_online/features/decorations/domain/models/public_decoration_list_item.dart';

class DecorationItem {
  final String id;
  final String title;
  final String providerName;
  final String price;
  final String imageUrl;
  final double rating;
  /// Optional subtitle (e.g. city name) shown below title.
  final String? subtitle;

  /// Listing line like `₹5,200 — ₹9,000` (from API base price). Empty → use [price].
  final String priceRangeDisplay;

  const DecorationItem({
    required this.id,
    required this.title,
    required this.providerName,
    required this.price,
    required this.imageUrl,
    this.rating = 4.5,
    this.subtitle,
    this.priceRangeDisplay = '',
  });

  String get displayPriceLine =>
      priceRangeDisplay.isNotEmpty ? priceRangeDisplay : price;

  /// Default wedding/decoration image when API has no thumbnail.
  static const String defaultImageUrl =
      'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=900&q=80';

  factory DecorationItem.fromPublic(PublicDecorationListItem item) {
    final eventType = item.eventTypeName.isNotEmpty ? item.eventTypeName : 'Decor';
    return DecorationItem(
      id: item.id,
      title: item.name,
      providerName: eventType,
      price: item.formattedPrice,
      priceRangeDisplay: _inrPriceRange(item.price),
      imageUrl: item.thumbnailUrl ?? defaultImageUrl,
      subtitle: item.cityName.isNotEmpty ? item.cityName : null,
    );
  }

  static String _inrPriceRange(double base) {
    final low = base.round();
    final high = (base * 1.35).round();
    return '₹${_commaInr(low)} — ₹${_commaInr(high)}';
  }

  static String _commaInr(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      if (i > 0 && fromEnd % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
