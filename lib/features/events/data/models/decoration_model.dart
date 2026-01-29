class DecorationModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final List<String> features;
  final bool isAvailable;
  
  DecorationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.features,
    this.isAvailable = true,
  });
  
  factory DecorationModel.fromJson(Map<String, dynamic> json) {
    return DecorationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      price: (json['price'] as num).toDouble(),
      features: List<String>.from(json['features'] as List),
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'features': features,
      'is_available': isAvailable,
    };
  }
}
