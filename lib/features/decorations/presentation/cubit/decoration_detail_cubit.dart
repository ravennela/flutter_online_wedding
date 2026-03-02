import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/decorations/domain/models/public_decoration_detail.dart';
import 'package:flutter_online/features/decorations/domain/repositories/public_decoration_repository.dart';

abstract class DecorationDetailState {
  const DecorationDetailState();
}

class DecorationDetailInitial extends DecorationDetailState {
  const DecorationDetailInitial();
}

class DecorationDetailLoading extends DecorationDetailState {
  const DecorationDetailLoading();
}

class DecorationDetailLoaded extends DecorationDetailState {
  final PublicDecorationDetail detail;

  const DecorationDetailLoaded(this.detail);
}

class DecorationDetailError extends DecorationDetailState {
  final String message;

  const DecorationDetailError(this.message);
}

class DecorationDetailCubit extends Cubit<DecorationDetailState> {
  final PublicDecorationRepository repository;

  DecorationDetailCubit(this.repository) : super(const DecorationDetailInitial());

  Future<void> loadDecorationDetail(String id) async {
    if (id.isEmpty) {
      emit(const DecorationDetailError('Invalid decoration ID'));
      return;
    }

    emit(const DecorationDetailLoading());

    final result = await repository.getDecorationDetail(id);

    result.fold(
      (error) => emit(DecorationDetailError(error)),
      (detail) => emit(DecorationDetailLoaded(detail)),
    );
  }
}
