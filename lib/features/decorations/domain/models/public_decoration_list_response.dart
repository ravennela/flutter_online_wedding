import 'package:flutter_online/features/decorations/domain/models/public_decoration_list_item.dart';

class PublicDecorationListResponse {
  final List<PublicDecorationListItem> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  const PublicDecorationListResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory PublicDecorationListResponse.fromJson(Map<String, dynamic> json) {
    final contentRaw = json['content'] as List<dynamic>? ?? [];
    return PublicDecorationListResponse(
      content: contentRaw
          .map((e) => PublicDecorationListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 10,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      last: json['last'] as bool? ?? true,
    );
  }
}
