import 'package:equatable/equatable.dart';

abstract class AddAddressState extends Equatable {
  const AddAddressState();

  @override
  List<Object?> get props => [];
}

class AddAddressInitial extends AddAddressState {}

class AddAddressValidating extends AddAddressState {}

class AddAddressLoading extends AddAddressState {}

class AddAddressSuccess extends AddAddressState {
  final String message;
  const AddAddressSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AddAddressFailure extends AddAddressState {
  final String error;
  const AddAddressFailure(this.error);

  @override
  List<Object?> get props => [error];
}
