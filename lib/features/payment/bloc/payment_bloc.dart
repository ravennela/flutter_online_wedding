import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_event.dart';
import 'payment_state.dart';
import '../domain/usecases/create_order_usecase.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreateOrderUseCase createOrderUseCase;

  PaymentBloc({required this.createOrderUseCase}) : super(PaymentInitial()) {
    on<CreateRazorpayOrder>(_onCreateRazorpayOrder);
  }

  Future<void> _onCreateRazorpayOrder(
    CreateRazorpayOrder event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await createOrderUseCase(event.bookingId, event.amountInRupees);

    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (response) => emit(RazorpayOrderCreated(response)),
    );
  }
}

