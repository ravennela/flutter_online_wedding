enum VendorStatus { available, notAvailable }
enum AssignmentStatus { none, pending, accepted }

class Vendor {
  final String id;
  final String name;
  final String imageUrl;
  final VendorStatus status;
  final String category;
  final String city;
  final double rating;
  final int eventCount;
  final String description;
  final AssignmentStatus assignmentStatus;
  final String? requestId; // ID for the assignment request if it exists

  Vendor({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.status,
    required this.category,
    required this.city,
    required this.rating,
    required this.eventCount,
    required this.description,
    this.assignmentStatus = AssignmentStatus.none,
    this.requestId,
  });

  bool get isAvailable => status == VendorStatus.available;
}

class SelectVendorArgs {
  final String bookingId;
  final String bookingCode;
  final String eventCategory;
  final String city;
  final String? assignedVendorId;

  SelectVendorArgs({
    required this.bookingId,
    required this.bookingCode,
    required this.eventCategory,
    required this.city,
    this.assignedVendorId,
  });
}
