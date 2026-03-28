import 'package:equatable/equatable.dart';

class AdminDashboardEntity extends Equatable {
  final AdminStatsEntity stats;
  final List<BookingOverviewEntity> bookingOverview;
  final AdminBookingStatusEntity bookingStatus;
  final List<AdminRecentBookingEntity> recentBookings;
  final List<AdminUpcomingEventEntity> upcomingEvents;
  final AdminPendingActionsEntity pendingActions;

  const AdminDashboardEntity({
    required this.stats,
    required this.bookingOverview,
    required this.bookingStatus,
    required this.recentBookings,
    required this.upcomingEvents,
    required this.pendingActions,
  });

  @override
  List<Object?> get props => [
        stats,
        bookingOverview,
        bookingStatus,
        recentBookings,
        upcomingEvents,
        pendingActions,
      ];
}

class AdminStatsEntity extends Equatable {
  final int totalBookings;
  final int todayEvents;
  final double monthlyRevenue;
  final int pendingActions;

  const AdminStatsEntity({
    required this.totalBookings,
    required this.todayEvents,
    required this.monthlyRevenue,
    required this.pendingActions,
  });

  @override
  List<Object?> get props => [totalBookings, todayEvents, monthlyRevenue, pendingActions];
}

class BookingOverviewEntity extends Equatable {
  final String day;
  final int count;

  const BookingOverviewEntity({
    required this.day,
    required this.count,
  });

  @override
  List<Object?> get props => [day, count];
}

class AdminBookingStatusEntity extends Equatable {
  final int confirmed;
  final int pending;
  final int cancelled;

  const AdminBookingStatusEntity({
    required this.confirmed,
    required this.pending,
    required this.cancelled,
  });

  @override
  List<Object?> get props => [confirmed, pending, cancelled];
}

class AdminRecentBookingEntity extends Equatable {
  final String? bookingId;
  final String customerName;
  final String eventType;
  final String status;

  const AdminRecentBookingEntity({
    this.bookingId,
    required this.customerName,
    required this.eventType,
    required this.status,
  });

  @override
  List<Object?> get props => [bookingId, customerName, eventType, status];
}

class AdminUpcomingEventEntity extends Equatable {
  final String title;
  final String date;
  final String? time;
  final String vendorName;
  final String status;

  const AdminUpcomingEventEntity({
    required this.title,
    required this.date,
    this.time,
    required this.vendorName,
    required this.status,
  });

  @override
  List<Object?> get props => [title, date, time, vendorName, status];
}

class AdminPendingActionsEntity extends Equatable {
  final int vendorAssignmentCount;
  final int paymentReviewCount;

  const AdminPendingActionsEntity({
    required this.vendorAssignmentCount,
    required this.paymentReviewCount,
  });

  @override
  List<Object?> get props => [vendorAssignmentCount, paymentReviewCount];
}
