import 'package:equatable/equatable.dart';
import '../../domain/models/address_entity.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressLoaded extends AddressState {
  final List<AddressEntity> addresses;

  const AddressLoaded(this.addresses);

  @override
  List<Object?> get props => [addresses];
}

class AddressEmpty extends AddressState {}

class AddressFailure extends AddressState {
  final String message;

  const AddressFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AddressDeleting extends AddressState {
  final String addressId;
  final List<AddressEntity> currentAddresses;

  const AddressDeleting({required this.addressId, required this.currentAddresses});

  @override
  List<Object?> get props => [addressId, currentAddresses];
}

class AddressDeleteSuccess extends AddressState {}
