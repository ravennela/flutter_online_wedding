import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/decorations/domain/models/public_decoration_list_item.dart';
import 'package:flutter_online/features/decorations/domain/models/public_decoration_list_response.dart';
import 'package:flutter_online/features/decorations/domain/repositories/public_decoration_repository.dart';

abstract class DecorationListState {
  const DecorationListState();
}

class DecorationListInitial extends DecorationListState {
  const DecorationListInitial();
}

class DecorationListLoading extends DecorationListState {
  const DecorationListLoading();
}

class DecorationListLoaded extends DecorationListState {
  final List<PublicDecorationListItem> decorations;
  final int page;
  final int totalPages;
  final bool hasMore;

  const DecorationListLoaded({
    required this.decorations,
    required this.page,
    required this.totalPages,
    required this.hasMore,
  });
}

class DecorationListEmpty extends DecorationListState {
  const DecorationListEmpty();
}

class DecorationListError extends DecorationListState {
  final String message;

  const DecorationListError(this.message);
}

class DecorationListCubit extends Cubit<DecorationListState> {
  final PublicDecorationRepository repository;

  DecorationListCubit(this.repository) : super(const DecorationListInitial());

  Future<void> loadDecorations({
    required String cityId,
    String? eventTypeId,
    int page = 0,
    int size = 10,
  }) async {
    if (cityId.isEmpty) {
      emit(const DecorationListError('Please select a city first'));
      return;
    }

    emit(const DecorationListLoading());

    final result = await repository.getDecorations(
      cityId: cityId,
      eventTypeId: eventTypeId,
      page: page,
      size: size,
    );

    result.fold(
      (error) => emit(DecorationListError(error)),
      (response) {
        if (response.content.isEmpty) {
          emit(const DecorationListEmpty());
        } else {
          emit(DecorationListLoaded(
            decorations: response.content,
            page: response.page,
            totalPages: response.totalPages,
            hasMore: !response.last,
          ));
        }
      },
    );
  }

  Future<void> loadMore({
    required String cityId,
    String? eventTypeId,
    int size = 10,
  }) async {
    final current = state;
    if (current is! DecorationListLoaded || !current.hasMore) return;

    final result = await repository.getDecorations(
      cityId: cityId,
      eventTypeId: eventTypeId,
      page: current.page + 1,
      size: size,
    );

    result.fold(
      (error) => emit(DecorationListError(error)),
      (response) => emit(DecorationListLoaded(
        decorations: [...current.decorations, ...response.content],
        page: response.page,
        totalPages: response.totalPages,
        hasMore: !response.last,
      )),
    );
  }
}
