import 'package:flutter_online/features/decorations/domain/models/public_decoration_list_item.dart';

class DecorationItem {
  final String id;
  final String title;
  final String providerName;
  final String price;
  final String imageUrl;
  final double rating;

  const DecorationItem({
    required this.id,
    required this.title,
    required this.providerName,
    required this.price,
    required this.imageUrl,
    this.rating = 4.5,
  });

  factory DecorationItem.fromPublic(PublicDecorationListItem item) {
    return DecorationItem(
      id: item.id,
      title: item.name,
      providerName: item.eventTypeName.isNotEmpty ? item.eventTypeName : item.cityName,
      price: item.formattedPrice,
      imageUrl: item.thumbnailUrl ?? 'https://placehold.co/600x400?text=No+Image',
    );
  }
}
