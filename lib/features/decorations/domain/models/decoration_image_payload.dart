/// Single image payload for create/update decoration (url + publicId from Cloudinary).
/// Sent as part of the `images` array to the backend so it can store in decoration_images.
class DecorationImagePayload {
  final String url;
  final String publicId;

  const DecorationImagePayload({
    required this.url,
    required this.publicId,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'publicId': publicId,
      };

  /// Backend may expect imageUrl instead of url.
  Map<String, dynamic> toJsonWithImageUrl() => {
        'imageUrl': url,
        'publicId': publicId,
      };

  /// Single map for POST/PUT: covers camelCase and snake_case Jackson DTOs.
  Map<String, dynamic> toApiMap() => {
        'imageUrl': url,
        'url': url,
        'publicId': publicId,
        'public_id': publicId,
      };
}
