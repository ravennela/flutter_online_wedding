class EventType {
  final String id;
  final String name;
  final String imageUrl;
  final String dateText;
  final String categoryTag; // badge text like TRADITIONAL, BIRTHDAY

  EventType({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.dateText,
    required this.categoryTag,
  });
}
