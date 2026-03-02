import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_booking_entity.dart';
import '../../domain/usecases/get_admin_bookings_usecase.dart';

// Events and States remained the same, just adding the Bloc class
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

class UpdateFilters extends AdminBookingsEvent {
  final String? status;
  final String? city;
  final String? paymentStatus;
  final String? query;

  const UpdateFilters({this.status, this.city, this.paymentStatus, this.query});

  @override
  List<Object?> get props => [status, city, paymentStatus, query];
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

enum AdminBookingsStatus { initial, loading, success, failure }

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
        errorMessage,
      ];
}

class AdminBookingsBloc extends Bloc<AdminBookingsEvent, AdminBookingsState> {
  final GetAdminBookingsUseCase getAdminBookingsUseCase;

  AdminBookingsBloc({required this.getAdminBookingsUseCase})
      : super(const AdminBookingsState()) {
    on<FetchAdminBookings>(_onFetchAdminBookings);
    on<UpdateFilters>(_onUpdateFilters);
    on<ChangePage>(_onChangePage);
    on<ChangePageSize>(_onChangePageSize);
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
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminBookingsStatus.failure,
        errorMessage: failure!.message??"",
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
      currentPage: 0, // Reset to first page on filter change
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
}
