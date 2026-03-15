/// Result of a successful file upload (e.g. Cloudinary via backend).
/// Store both [url] and [publicId] so they can be sent to APIs and stored in DB.
class UploadResult {
  final String url;
  final String publicId;

  const UploadResult({
    required this.url,
    required this.publicId,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    final url = json['url']?.toString() ??
        json['secure_url']?.toString() ??
        json['secureUrl']?.toString() ??
        '';
    final publicId = json['publicId']?.toString() ??
        json['public_id']?.toString() ??
        '';
    return UploadResult(url: url, publicId: publicId);
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'publicId': publicId,
      };
}
