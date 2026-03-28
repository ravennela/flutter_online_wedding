import 'package:flutter_online/core/constants/api_constants.dart';
import 'package:flutter_online/core/network/api_client.dart';
import 'package:flutter_online/features/profile/domain/models/user_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile> getUserProfile();
  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String cityId,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserProfile> getUserProfile() async {
    String url=ApiConstants.userProfile;
    final response = await apiClient.get(url);
    return UserProfile.fromJson(response.data);
  }

  @override
  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String cityId,
  }) async {
    String url=ApiConstants.userProfile;
    await apiClient.put(
     url,
      data: {
        'name': name,
        'email': email,
        'cityId': cityId,
      },
    );
  }
}
