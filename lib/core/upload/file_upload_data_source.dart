import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../network/api_client.dart';
import 'models/upload_result.dart';
import 'upload_folder.dart';

/// Reusable file upload (e.g. Cloudinary via backend).
/// Kept separate so it can be used by events, decorations, etc. without mixing with feature logic.
abstract class FileUploadDataSource {
  /// Uploads [fileBytes] with [filename] to the given [folder].
  /// Returns [UploadResult] with [url] and [publicId] to send to backend and store in DB.
  Future<UploadResult> upload({
    required List<int> fileBytes,
    required String filename,
    required UploadFolder folder,
  });
}

class FileUploadDataSourceImpl implements FileUploadDataSource {
  final ApiClient apiClient;

  FileUploadDataSourceImpl(this.apiClient);

  @override
  Future<UploadResult> upload({
    required List<int> fileBytes,
    required String filename,
    required UploadFolder folder,
  }) async {
    final formData = FormData.fromMap({
      'folder': folder.value,
      'file': MultipartFile.fromBytes(
        fileBytes,
        filename: filename,
      ),
    });

    final response = await apiClient.post(
      ApiConstants.catalogUpload,
      data: formData,
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Upload response was not a map');
    }
    return UploadResult.fromJson(data);
  }
}
