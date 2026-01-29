class DecorationDetail {
  final String id;
  final String title;
  final String providerName;
  final String providerImage;
  final String price;
  final String startingPriceLabel;
  final double rating;
  final List<String> images;
  final List<String> tags;
  final Map<String, String> features; // Title: Description
  final String description;

  const DecorationDetail({
    required this.id,
    required this.title,
    required this.providerName,
    required this.providerImage,
    required this.price,
    this.startingPriceLabel = "Starting from",
    required this.rating,
    required this.images,
    required this.tags,
    required this.features,
    this.description = '',
  });
}
