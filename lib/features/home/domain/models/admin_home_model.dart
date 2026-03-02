/// Admin Home API response models.
/// Handles null values from API for optional fields.

class AdminHomeModel {
  final AdminHomeHeroModel hero;
  final List<AdminHomeCategoryModel> categories;
  final List<AdminHomeServiceModel> services;
  final List<AdminHomeFeaturedEventModel> featuredEvents;
  final List<AdminHomeRealCelebrationModel> realCelebrations;
  final List<AdminHomeTrendingDecorationModel> trendingDecorations;

  const AdminHomeModel({
    required this.hero,
    required this.categories,
    required this.services,
    required this.featuredEvents,
    required this.realCelebrations,
    required this.trendingDecorations,
  });

  factory AdminHomeModel.fromJson(Map<String, dynamic> json) {
    final featuredEventRaw = json['featuredEvent'];
    List<AdminHomeFeaturedEventModel> featuredEvents = [];
    if (featuredEventRaw != null) {
      if (featuredEventRaw is List) {
        featuredEvents = featuredEventRaw
            .map((e) => AdminHomeFeaturedEventModel.fromJson(
                  e as Map<String, dynamic>,
                ))
            .toList();
      } else if (featuredEventRaw is Map<String, dynamic>) {
        featuredEvents = [
          AdminHomeFeaturedEventModel.fromJson(featuredEventRaw),
        ];
      }
    }
    return AdminHomeModel(
      hero: AdminHomeHeroModel.fromJson(
        json['hero'] as Map<String, dynamic>? ?? {},
      ),
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => AdminHomeCategoryModel.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => AdminHomeServiceModel.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      featuredEvents: featuredEvents,
      realCelebrations: (json['realCelebrations'] as List<dynamic>?)
              ?.map((e) => AdminHomeRealCelebrationModel.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      trendingDecorations: (json['trendingDecorations'] as List<dynamic>?)
              ?.map((e) => AdminHomeTrendingDecorationModel.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
    );
  }
}

class AdminHomeHeroModel {
  final String title;
  final String subtitle;
  final String? imageUrl;

  const AdminHomeHeroModel({
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });

  factory AdminHomeHeroModel.fromJson(Map<String, dynamic> json) {
    return AdminHomeHeroModel(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class AdminHomeCategoryModel {
  final String id;
  final String name;
  final String icon;
  final String? imageUrl;

  const AdminHomeCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.imageUrl,
  });

  factory AdminHomeCategoryModel.fromJson(Map<String, dynamic> json) {
    return AdminHomeCategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? 'default_icon',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class AdminHomeServiceModel {
  final String title;
  final String description;
  final String icon;

  const AdminHomeServiceModel({
    required this.title,
    required this.description,
    required this.icon,
  });

  factory AdminHomeServiceModel.fromJson(Map<String, dynamic> json) {
    return AdminHomeServiceModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
    );
  }
}

class AdminHomeFeaturedEventModel {
  final String? id;
  final String title;
  final String subtitle;
  final String? imageUrl;

  const AdminHomeFeaturedEventModel({
    this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });

  factory AdminHomeFeaturedEventModel.fromJson(Map<String, dynamic> json) {
    return AdminHomeFeaturedEventModel(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class AdminHomeRealCelebrationModel {
  final String title;
  final String type;
  final String? imageUrl;

  const AdminHomeRealCelebrationModel({
    required this.title,
    required this.type,
    this.imageUrl,
  });

  factory AdminHomeRealCelebrationModel.fromJson(Map<String, dynamic> json) {
    return AdminHomeRealCelebrationModel(
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class AdminHomeTrendingDecorationModel {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;

  const AdminHomeTrendingDecorationModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  factory AdminHomeTrendingDecorationModel.fromJson(Map<String, dynamic> json) {
    return AdminHomeTrendingDecorationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
