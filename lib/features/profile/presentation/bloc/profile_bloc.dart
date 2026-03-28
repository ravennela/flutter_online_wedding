import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/profile/domain/usecase/get_profile_usecase.dart';
import 'package:flutter_online/features/profile/domain/usecase/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial()) {
    on<GetProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      final result = await getProfileUseCase();
      result.fold(
        (failure) => emit(ProfileError(failure)),
        (profile) => emit(ProfileLoaded(profile)),
      );
    });

    on<UpdateProfileEvent>((event, emit) async {
      final currentState = state;
      emit(ProfileUpdating());
      final result = await updateProfileUseCase(
        name: event.name,
        email: event.email,
        cityId: event.cityId,
      );
      result.fold(
        (failure) => emit(ProfileError(failure)),
        (_) => emit(ProfileUpdateSuccess()),
      );
    });
  }
}
