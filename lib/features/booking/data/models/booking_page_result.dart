import 'booking_model.dart';

/// Result of a paginated "my bookings" API response (Spring Page format).
class BookingPageResult {
  final List<BookingModel> content;
  final bool last;
  final int totalElements;
  final int number; // 0-based page index
  final int size;    // page size

  const BookingPageResult({
    required this.content,
    required this.last,
    required this.totalElements,
    required this.number,
    required this.size,
  });

  bool get hasMore => !last;

  factory BookingPageResult.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>? ?? [];
    return BookingPageResult(
      content: contentList
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      last: json['last'] as bool? ?? true,
      totalElements: json['totalElements'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      size: json['size'] as int? ?? 10,
    );
  }
}
