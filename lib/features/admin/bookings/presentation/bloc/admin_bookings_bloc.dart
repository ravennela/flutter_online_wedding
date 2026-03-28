import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_booking_entity.dart';
import '../../domain/usecases/get_admin_bookings_usecase.dart';
import '../../domain/usecases/update_booking_status_usecase.dart';
import '../../domain/usecases/admin_cancel_booking_usecase.dart';
import 'package:flutter_online/features/events/domain/models/event_type_list_item.dart';
import 'package:flutter_online/features/events/domain/usecases/fetch_event_types_usecase.dart';

// Events and States
abstract class AdminBookingsEvent extends Equatable {
  const AdminBookingsEvent();
  @override
  List<Object?> get props => [];
}

class FetchAdminBookings extends AdminBookingsEvent {
  final bool isRefresh;
  const FetchAdminBookings({this.isRefresh = false});
  @override
  List<Object?> get props => [isRefresh];
}

class FetchEventTypes extends AdminBookingsEvent {
  const FetchEventTypes();
}


class UpdateFilters extends AdminBookingsEvent {
  final String? status;
  final String? city;
  final String? paymentStatus;
  final String? query;
  final String? startDate;
  final String? endDate;
  final String? eventType;

  const UpdateFilters({
    this.status,
    this.city,
    this.paymentStatus,
    this.query,
    this.startDate,
    this.endDate,
    this.eventType,
  });

  @override
  List<Object?> get props => [status, city, paymentStatus, query, startDate, endDate, eventType];
}


class ChangePage extends AdminBookingsEvent {
  final int page;
  const ChangePage(this.page);
  @override
  List<Object?> get props => [page];
}

class ChangePageSize extends AdminBookingsEvent {
  final int pageSize;
  const ChangePageSize(this.pageSize);
  @override
  List<Object?> get props => [pageSize];
}

class UpdateBookingStatusInList extends AdminBookingsEvent {
  final String id;
  final String status;
  const UpdateBookingStatusInList(this.id, this.status);
  @override
  List<Object?> get props => [id, status];
}

class AdminCancelBookingInList extends AdminBookingsEvent {
  final String id;
  final String reason;
  const AdminCancelBookingInList(this.id, this.reason);
  @override
  List<Object?> get props => [id, reason];
}

enum AdminBookingsStatus { initial, loading, success, failure, updating, updateSuccess, updateFailure, cancelling, cancelSuccess, cancelFailure }

class AdminBookingsState extends Equatable {
  final AdminBookingsStatus status;
  final List<AdminBookingEntity> bookings;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalItems;
  final String? selectedStatus;
  final String? selectedCity;
  final String? selectedPaymentStatus;
  final String? searchQuery;
  final String? selectedStartDate;
  final String? selectedEndDate;

  final String? selectedEventType; // This can be name or ID
  final List<EventTypeListItem> eventTypes;
  final String? errorMessage;

  const AdminBookingsState({
    this.status = AdminBookingsStatus.initial,
    this.bookings = const [],
    this.currentPage = 0,
    this.totalPages = 0,
    this.pageSize = 10,
    this.totalItems = 0,
    this.selectedStatus,
    this.selectedCity,
    this.selectedPaymentStatus,
    this.searchQuery,
    this.selectedStartDate,
    this.selectedEndDate,
    this.selectedEventType,
    this.eventTypes = const [],
    this.errorMessage,
  });



  AdminBookingsState copyWith({
    AdminBookingsStatus? status,
    List<AdminBookingEntity>? bookings,
    int? currentPage,
    int? totalPages,
    int? pageSize,
    int? totalItems,
    String? selectedStatus,
    String? selectedCity,
    String? selectedPaymentStatus,
    String? searchQuery,
    String? selectedStartDate,
    String? selectedEndDate,
    String? selectedEventType,
    List<EventTypeListItem>? eventTypes,
    String? errorMessage,
  }) {
    return AdminBookingsState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedPaymentStatus: selectedPaymentStatus ?? this.selectedPaymentStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStartDate: selectedStartDate ?? this.selectedStartDate,
      selectedEndDate: selectedEndDate ?? this.selectedEndDate,
      selectedEventType: selectedEventType ?? this.selectedEventType,
      eventTypes: eventTypes ?? this.eventTypes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }



  @override
  List<Object?> get props => [
        status,
        bookings,
        currentPage,
        totalPages,
        pageSize,
        totalItems,
        selectedStatus,
        selectedCity,
        selectedPaymentStatus,
        searchQuery,
        selectedStartDate,
        selectedEndDate,
        selectedEventType,
        eventTypes,
        errorMessage,
      ];

}


class AdminBookingsBloc extends Bloc<AdminBookingsEvent, AdminBookingsState> {
  final GetAdminBookingsUseCase getAdminBookingsUseCase;
  final UpdateBookingStatusUseCase updateBookingStatusUseCase;
  final AdminCancelBookingUseCase adminCancelBookingUseCase;
  final FetchEventTypesUsecase fetchEventTypesUsecase;

  AdminBookingsBloc({
    required this.getAdminBookingsUseCase,
    required this.updateBookingStatusUseCase,
    required this.adminCancelBookingUseCase,
    required this.fetchEventTypesUsecase,
  }) : super(const AdminBookingsState()) {
    on<FetchAdminBookings>(_onFetchAdminBookings);
    on<FetchEventTypes>(_onFetchEventTypes);
    on<UpdateFilters>(_onUpdateFilters);
    on<ChangePage>(_onChangePage);
    on<ChangePageSize>(_onChangePageSize);
    on<UpdateBookingStatusInList>(_onUpdateBookingStatus);
    on<AdminCancelBookingInList>(_onAdminCancelBooking);
  }

  Future<void> _onFetchEventTypes(
    FetchEventTypes event,
    Emitter<AdminBookingsState> emit,
  ) async {
    final result = await fetchEventTypesUsecase(page: 0, size: 100);
    result.fold(
      (failure) => null, // Ignore failures for now or log them
      (response) => emit(state.copyWith(eventTypes: response.content)),
    );
  }


  Future<void> _onFetchAdminBookings(
    FetchAdminBookings event,
    Emitter<AdminBookingsState> emit,
  ) async {
    emit(state.copyWith(status: AdminBookingsStatus.loading));

    final result = await getAdminBookingsUseCase(AdminBookingParams(
      page: state.currentPage,
      size: state.pageSize,
      status: state.selectedStatus,
      city: state.selectedCity,
      paymentStatus: state.selectedPaymentStatus,
      search: state.searchQuery,
      startDate: state.selectedStartDate,
      endDate: state.selectedEndDate,
      eventTypeId: state.selectedEventType,
    ));


    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminBookingsStatus.failure,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: AdminBookingsStatus.success,
        bookings: data.content,
        totalPages: data.totalPages,
        totalItems: data.totalElements,
      )),
    );
  }

  Future<void> _onUpdateFilters(
    UpdateFilters event,
    Emitter<AdminBookingsState> emit,
  ) async {
    emit(state.copyWith(
      selectedStatus: event.status ?? state.selectedStatus,
      selectedCity: event.city ?? state.selectedCity,
      selectedPaymentStatus: event.paymentStatus ?? state.selectedPaymentStatus,
      searchQuery: event.query ?? state.searchQuery,
      selectedStartDate: event.startDate ?? state.selectedStartDate,
      selectedEndDate: event.endDate ?? state.selectedEndDate,
      selectedEventType: event.eventType ?? state.selectedEventType,
      currentPage: 0,
    ));
    add(const FetchAdminBookings());
  }


  Future<void> _onChangePage(
    ChangePage event,
    Emitter<AdminBookingsState> emit,
  ) async {
    emit(state.copyWith(currentPage: event.page));
    add(const FetchAdminBookings());
  }

  Future<void> _onChangePageSize(
    ChangePageSize event,
    Emitter<AdminBookingsState> emit,
  ) async {
    emit(state.copyWith(pageSize: event.pageSize, currentPage: 0));
    add(const FetchAdminBookings());
  }

  Future<void> _onUpdateBookingStatus(
    UpdateBookingStatusInList event,
    Emitter<AdminBookingsState> emit,
  ) async {
    emit(state.copyWith(status: AdminBookingsStatus.updating));

    final result = await updateBookingStatusUseCase(event.id, event.status);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminBookingsStatus.updateFailure,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(status: AdminBookingsStatus.updateSuccess));
        add(const FetchAdminBookings());
      },
    );
  }

  Future<void> _onAdminCancelBooking(
    AdminCancelBookingInList event,
    Emitter<AdminBookingsState> emit,
  ) async {
    emit(state.copyWith(status: AdminBookingsStatus.cancelling));

    final result = await adminCancelBookingUseCase(event.id, event.reason);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminBookingsStatus.cancelFailure,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(status: AdminBookingsStatus.cancelSuccess));
        add(const FetchAdminBookings());
      },
    );
  }
}
