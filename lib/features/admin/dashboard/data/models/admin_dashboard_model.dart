import '../../domain/entities/admin_dashboard_entity.dart';

class AdminDashboardModel extends AdminDashboardEntity {
  const AdminDashboardModel({
    required super.stats,
    required super.bookingOverview,
    required super.bookingStatus,
    required super.recentBookings,
    required super.upcomingEvents,
    required super.pendingActions,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      stats: AdminStatsModel.fromJson(json['stats'] ?? {}),
      bookingOverview: (json['bookingOverview'] as List? ?? [])
          .map((e) => BookingOverviewModel.fromJson(e))
          .toList(),
      bookingStatus: AdminBookingStatusModel.fromJson(json['bookingStatus'] ?? {}),
      recentBookings: (json['recentBookings'] as List? ?? [])
          .map((e) => AdminRecentBookingModel.fromJson(e))
          .toList(),
      upcomingEvents: (json['upcomingEvents'] as List? ?? [])
          .map((e) => AdminUpcomingEventModel.fromJson(e))
          .toList(),
      pendingActions: AdminPendingActionsModel.fromJson(json['pendingActions'] ?? {}),
    );
  }
}

class AdminStatsModel extends AdminStatsEntity {
  const AdminStatsModel({
    required super.totalBookings,
    required super.todayEvents,
    required super.monthlyRevenue,
    required super.pendingActions,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalBookings: (json['totalBookings'] as num? ?? 0).toInt(),
      todayEvents: (json['todayEvents'] as num? ?? 0).toInt(),
      monthlyRevenue: (json['monthlyRevenue'] as num? ?? 0.0).toDouble(),
      pendingActions: (json['pendingActions'] as num? ?? 0).toInt(),
    );
  }
}

class BookingOverviewModel extends BookingOverviewEntity {
  const BookingOverviewModel({
    required super.day,
    required super.count,
  });

  factory BookingOverviewModel.fromJson(Map<String, dynamic> json) {
    return BookingOverviewModel(
      day: json['day'] as String? ?? '',
      count: (json['count'] as num? ?? 0).toInt(),
    );
  }
}

class AdminBookingStatusModel extends AdminBookingStatusEntity {
  const AdminBookingStatusModel({
    required super.confirmed,
    required super.pending,
    required super.cancelled,
  });

  factory AdminBookingStatusModel.fromJson(Map<String, dynamic> json) {
    return AdminBookingStatusModel(
      confirmed: (json['confirmed'] as num? ?? 0).toInt(),
      pending: (json['pending'] as num? ?? 0).toInt(),
      cancelled: (json['cancelled'] as num? ?? 0).toInt(),
    );
  }
}

class AdminRecentBookingModel extends AdminRecentBookingEntity {
  const AdminRecentBookingModel({
    super.bookingId,
    required super.customerName,
    required super.eventType,
    required super.status,
  });

  factory AdminRecentBookingModel.fromJson(Map<String, dynamic> json) {
    return AdminRecentBookingModel(
      bookingId: json['bookingId']?.toString(),
      customerName: json['customerName'] as String? ?? 'N/A',
      eventType: json['eventType'] as String? ?? 'N/A',
      status: json['status'] as String? ?? 'N/A',
    );
  }
}

class AdminUpcomingEventModel extends AdminUpcomingEventEntity {
  const AdminUpcomingEventModel({
    required super.title,
    required super.date,
    super.time,
    required super.vendorName,
    required super.status,
  });

  factory AdminUpcomingEventModel.fromJson(Map<String, dynamic> json) {
    return AdminUpcomingEventModel(
      title: json['title'] as String? ?? 'N/A',
      date: json['date'] as String? ?? '',
      time: json['time']?.toString(),
      vendorName: json['vendorName'] as String? ?? 'Not Assigned',
      status: json['status'] as String? ?? 'N/A',
    );
  }
}

class AdminPendingActionsModel extends AdminPendingActionsEntity {
  const AdminPendingActionsModel({
    required super.vendorAssignmentCount,
    required super.paymentReviewCount,
  });

  factory AdminPendingActionsModel.fromJson(Map<String, dynamic> json) {
    return AdminPendingActionsModel(
      vendorAssignmentCount: (json['vendorAssignmentCount'] as num? ?? 0).toInt(),
      paymentReviewCount: (json['paymentReviewCount'] as num? ?? 0).toInt(),
    );
  }
}
