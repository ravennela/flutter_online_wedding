import 'package:flutter_online/features/decorations/domain/models/decoration_list_item.dart';

class DecorationListResponse {
  final List<DecorationListItem> content;
  final bool last;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  const DecorationListResponse({
    required this.content,
    required this.last,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory DecorationListResponse.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>? ?? [];
    return DecorationListResponse(
      content: contentList
          .map((e) => DecorationListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      last: json['last'] as bool? ?? true,
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 10,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}
