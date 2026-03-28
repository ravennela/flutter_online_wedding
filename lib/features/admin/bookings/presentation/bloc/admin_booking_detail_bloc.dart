import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/admin_booking_entity.dart';
import '../../domain/usecases/get_admin_booking_detail_usecase.dart';
import '../../domain/usecases/update_booking_status_usecase.dart';
import '../../domain/usecases/admin_cancel_booking_usecase.dart';
import '../../domain/usecases/assign_vendors_usecase.dart';
import '../../domain/usecases/deassign_vendor_usecase.dart';
import '../../domain/usecases/update_booking_detail_usecase.dart';

// Events
abstract class AdminBookingDetailEvent extends Equatable {
  const AdminBookingDetailEvent();
  @override
  List<Object?> get props => [];
}

class FetchBookingDetail extends AdminBookingDetailEvent {
  final String id;
  const FetchBookingDetail(this.id);
  @override
  List<Object?> get props => [id];
}

class UpdateBookingStatus extends AdminBookingDetailEvent {
  final String id;
  final String status;
  const UpdateBookingStatus(this.id, this.status);
  @override
  List<Object?> get props => [id, status];
}

class AdminCancelBooking extends AdminBookingDetailEvent {
  final String id;
  final String reason;
  const AdminCancelBooking(this.id, this.reason);
  @override
  List<Object?> get props => [id, reason];
}

class AssignVendors extends AdminBookingDetailEvent {
  final String bookingId;
  final List<String> vendorIds;
  const AssignVendors(this.bookingId, this.vendorIds);
  @override
  List<Object?> get props => [bookingId, vendorIds];
}

class DeAssignVendor extends AdminBookingDetailEvent {
  final String bookingId;
  final String vendorId;
  const DeAssignVendor(this.bookingId, this.vendorId);
  @override
  List<Object?> get props => [bookingId, vendorId];
}

class UpdateBookingDetail extends AdminBookingDetailEvent {
  final String id;
  final Map<String, dynamic> data;
  const UpdateBookingDetail(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

// State
enum AdminBookingDetailStatus {
  initial,
  loading,
  success,
  failure,
  updating,
  updateSuccess,
  updateFailure,
  cancelling,
  cancelSuccess,
  cancelFailure,
  assigning,
  assignSuccess,
  assignFailure,
  deAssigning,
  deAssignSuccess,
  deAssignFailure,
}

class AdminBookingDetailState extends Equatable {
  final AdminBookingDetailStatus status;
  final AdminBookingDetailEntity? booking;
  final String? errorMessage;

  const AdminBookingDetailState({
    this.status = AdminBookingDetailStatus.initial,
    this.booking,
    this.errorMessage,
  });

  AdminBookingDetailState copyWith({
    AdminBookingDetailStatus? status,
    AdminBookingDetailEntity? booking,
    String? errorMessage,
  }) {
    return AdminBookingDetailState(
      status: status ?? this.status,
      booking: booking ?? this.booking,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, booking, errorMessage];
}

// Bloc
class AdminBookingDetailBloc
    extends Bloc<AdminBookingDetailEvent, AdminBookingDetailState> {
  final GetAdminBookingDetailUseCase getAdminBookingDetailUseCase;
  final UpdateBookingStatusUseCase updateBookingStatusUseCase;
  final AdminCancelBookingUseCase adminCancelBookingUseCase;
  final AssignVendorsUseCase assignVendorsUseCase;
  final DeAssignVendorUseCase deAssignVendorUseCase;
  final UpdateBookingDetailUseCase updateBookingDetailUseCase;

  AdminBookingDetailBloc({
    required this.getAdminBookingDetailUseCase,
    required this.updateBookingStatusUseCase,
    required this.adminCancelBookingUseCase,
    required this.assignVendorsUseCase,
    required this.deAssignVendorUseCase,
    required this.updateBookingDetailUseCase,
  }) : super(const AdminBookingDetailState()) {
    on<FetchBookingDetail>(_onFetchBookingDetail);
    on<UpdateBookingStatus>(_onUpdateBookingStatus);
    on<AdminCancelBooking>(_onAdminCancelBooking);
    on<AssignVendors>(_onAssignVendors);
    on<DeAssignVendor>(_onDeAssignVendor);
    on<UpdateBookingDetail>(_onUpdateBookingDetail);
  }

  Future<void> _onFetchBookingDetail(
    FetchBookingDetail event,
    Emitter<AdminBookingDetailState> emit,
  ) async {
    emit(state.copyWith(status: AdminBookingDetailStatus.loading));

    final result = await getAdminBookingDetailUseCase(event.id);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AdminBookingDetailStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (booking) => emit(
        state.copyWith(
          status: AdminBookingDetailStatus.success,
          booking: booking,
        ),
      ),
    );
  }

  Future<void> _onUpdateBookingStatus(
    UpdateBookingStatus event,
    Emitter<AdminBookingDetailState> emit,
  ) async {
    emit(state.copyWith(status: AdminBookingDetailStatus.updating));

    final result = await updateBookingStatusUseCase(event.id, event.status);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AdminBookingDetailStatus.updateFailure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(state.copyWith(status: AdminBookingDetailStatus.updateSuccess));
        add(FetchBookingDetail(event.id));
      },
    );
  }

  Future<void> _onAdminCancelBooking(
    AdminCancelBooking event,
    Emitter<AdminBookingDetailState> emit,
  ) async {
    emit(state.copyWith(status: AdminBookingDetailStatus.cancelling));

    final result = await adminCancelBookingUseCase(event.id, event.reason);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AdminBookingDetailStatus.cancelFailure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(state.copyWith(status: AdminBookingDetailStatus.cancelSuccess));
        add(FetchBookingDetail(event.id));
      },
    );
  }

  Future<void> _onAssignVendors(
    AssignVendors event,
    Emitter<AdminBookingDetailState> emit,
  ) async {
    emit(state.copyWith(status: AdminBookingDetailStatus.assigning));

    final result = await assignVendorsUseCase(event.bookingId, event.vendorIds);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AdminBookingDetailStatus.assignFailure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(state.copyWith(status: AdminBookingDetailStatus.assignSuccess));
        add(FetchBookingDetail(event.bookingId));
      },
    );
  }

  Future<void> _onDeAssignVendor(
    DeAssignVendor event,
    Emitter<AdminBookingDetailState> emit,
  ) async {
    emit(state.copyWith(status: AdminBookingDetailStatus.deAssigning));

    final result = await deAssignVendorUseCase(event.bookingId, event.vendorId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AdminBookingDetailStatus.deAssignFailure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(state.copyWith(status: AdminBookingDetailStatus.deAssignSuccess));
        add(FetchBookingDetail(event.bookingId));
      },
    );
  }

  Future<void> _onUpdateBookingDetail(
    UpdateBookingDetail event,
    Emitter<AdminBookingDetailState> emit,
  ) async {
    emit(state.copyWith(status: AdminBookingDetailStatus.updating));

    final result = await updateBookingDetailUseCase(event.id, event.data);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AdminBookingDetailStatus.updateFailure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(state.copyWith(status: AdminBookingDetailStatus.updateSuccess));
        add(FetchBookingDetail(event.id));
      },
    );
  }
}
