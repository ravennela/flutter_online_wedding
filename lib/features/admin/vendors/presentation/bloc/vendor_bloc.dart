import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_vendors_usecase.dart';
import 'vendor_event.dart';
import 'vendor_state.dart';

class VendorBloc extends Bloc<VendorEvent, VendorState> {
  final GetVendorsUseCase getVendorsUseCase;

  VendorBloc({required this.getVendorsUseCase}) : super(VendorInitial()) {
    on<GetVendorsEvent>(_onGetVendors);
  }

  Future<void> _onGetVendors(
    GetVendorsEvent event,
    Emitter<VendorState> emit,
  ) async {
    emit(VendorLoading());
    final result = await getVendorsUseCase(bookingId: event.bookingId);
    result.fold(
      (failure) => emit(VendorError(message: failure.message)),
      (vendors) => emit(VendorLoaded(vendors: vendors)),
    );
  }
}
