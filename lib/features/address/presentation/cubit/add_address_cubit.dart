import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_state.dart';

import '../../domain/models/address_entity.dart';
import '../../domain/usecases/create_address_usecase.dart';
import 'add_address_state.dart';

class AddAddressCubit extends Cubit<AddAddressState> {
  final CreateAddressUseCase createAddressUseCase;
  final AuthCubit authCubit;

  AddAddressCubit({
    required this.createAddressUseCase,
    required this.authCubit,
  }) : super(AddAddressInitial());

  Future<void> createAddress(AddressEntity address) async {
    final authState = authCubit.state;
    if (authState is! AuthAuthenticated) {
      emit(const AddAddressFailure('You must be logged in to add an address'));
      return;
    }

    final userId = authState.user.userId;
    if (userId.isEmpty) {
       emit(const AddAddressFailure('User session invalid. Please login again.'));
       return;
    }

    emit(AddAddressLoading());

    final result = await createAddressUseCase(address, userId);

    result.fold(
      (failure) => emit(AddAddressFailure(failure.message)),
      (success) => emit(const AddAddressSuccess('Address saved successfully!')),
    );
  }

  void reset() {
    emit(AddAddressInitial());
  }
}
