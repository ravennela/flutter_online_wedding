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

  const DecorationItem({
    required this.id,
    required this.title,
    required this.providerName,
    required this.price,
    required this.imageUrl,
    this.rating = 4.5,
    this.subtitle,
  });

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
      imageUrl: item.thumbnailUrl ?? defaultImageUrl,
      subtitle: item.cityName.isNotEmpty ? item.cityName : null,
    );
  }
}
