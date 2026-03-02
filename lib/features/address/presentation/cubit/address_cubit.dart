import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/address/domain/models/address_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/usecases/get_addresses_usecase.dart';
import '../../domain/usecases/delete_address_usecase.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final GetAddressesUseCase getAddressesUseCase;
  final DeleteAddressUseCase deleteAddressUseCase;
  final AuthCubit authCubit;

  AddressCubit({
    required this.getAddressesUseCase,
    required this.deleteAddressUseCase,
    required this.authCubit,
  }) : super(AddressInitial());

  Future<void> fetchAddresses() async {
    final authState = authCubit.state;
    if (authState is! AuthAuthenticated) {
      emit(const AddressFailure('You must be logged in to view addresses'));
      return;
    }

    final userId = authState.user.userId;
    if (userId.isEmpty) {
      emit(const AddressFailure('User session invalid. Please login again.'));
      return;
    }

    emit(AddressLoading());

    final result = await getAddressesUseCase(userId);

    result.fold(
      (failure) => emit(AddressFailure(failure.message)),
      (addresses) {
        if (addresses.isEmpty) {
          emit(AddressEmpty());
        } else {
          // Sort list so default address appears first
          addresses.sort((a, b) {
            if (a.isDefault && !b.isDefault) return -1;
            if (!a.isDefault && b.isDefault) return 1;
            return 0;
          });
          emit(AddressLoaded(addresses));
        }
      },
    );
  }

  Future<void> deleteAddress(String id) async {
    final currentState = state;
    List<AddressEntity> currentAddresses = [];
    if (currentState is AddressLoaded) {
      currentAddresses = currentState.addresses;
    } else if (currentState is AddressDeleting) {
      currentAddresses = currentState.currentAddresses;
    }

    emit(AddressDeleting(addressId: id, currentAddresses: currentAddresses));
    final result = await deleteAddressUseCase(id);

    result.fold(
      (failure) => emit(AddressFailure(failure.message)),
      (_) {
        emit(AddressDeleteSuccess());
        fetchAddresses();
      },
    );
  }
}
