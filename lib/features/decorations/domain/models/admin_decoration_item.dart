/// Admin-facing decoration list item for the decoration management screen.
/// Used for viewing, filtering, and managing decoration packages.
class AdminDecorationItem {
  final String id;
  final String imageUrl;
  final String eventType;
  final String name;
  final String city;
  final String venue;
  final String basePrice;
  final bool isActive;

  const AdminDecorationItem({
    required this.id,
    required this.imageUrl,
    required this.eventType,
    required this.name,
    required this.city,
    required this.venue,
    required this.basePrice,
    this.isActive = true,
  });

  String get cityVenue => venue.isNotEmpty ? '$city • $venue' : city;
}
