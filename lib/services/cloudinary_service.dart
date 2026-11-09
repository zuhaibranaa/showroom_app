import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Cloudinary config for image uploads on the Spark (free) plan, where
/// Firebase Storage is unavailable.
///
/// Create an *unsigned* upload preset in the Cloudinary dashboard
/// (Settings → Upload → Upload presets → Add → Signing Mode: Unsigned).
class CloudinaryConfig {
  const CloudinaryConfig._();

  /// Your Cloudinary cloud name (dashboard → top-left).
  static const String cloudName = 'dizy9vwqd';

  /// Name of the unsigned upload preset.
  static const String uploadPreset = 'ml_default';

  static bool get isConfigured =>
      cloudName.trim().isNotEmpty && uploadPreset.trim().isNotEmpty;
}

/// Uploads images to Cloudinary using an unsigned upload preset (same pattern
/// as expense_split).
class CloudinaryService {
  CloudinaryService._();

  static final CloudinaryService _instance = CloudinaryService._();
  factory CloudinaryService() => _instance;

  /// Upload a single image to Cloudinary. Returns the secure URL.
  Future<String> uploadImage(File imageFile, {String folder = 'showroom'}) async {
    if (!CloudinaryConfig.isConfigured) {
      throw Exception(
        'Image uploads are not configured. Set cloudName and '
        'uploadPreset in lib/services/cloudinary_service.dart.',
      );
    }

    final bytes = await imageFile.readAsBytes();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://api.cloudinary.com/v1_1/'
        '${CloudinaryConfig.cloudName}/image/upload',
      ),
    )
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = folder
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.path.split('/').last.isEmpty
              ? 'image.jpg'
              : imageFile.path.split('/').last,
        ),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Image upload failed (${response.statusCode}): $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final url = json['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Cloudinary did not return an image URL.');
    }

    return url;
  }

  /// Upload multiple images to Cloudinary. Returns list of secure URLs.
  Future<List<String>> uploadImages(
    List<File> imageFiles, {
    String folder = 'showroom',
  }) async {
    final urls = <String>[];
    for (final file in imageFiles) {
      final url = await uploadImage(file, folder: folder);
      urls.add(url);
    }
    return urls;
  }
}
