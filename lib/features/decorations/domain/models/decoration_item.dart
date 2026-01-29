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
}
