import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/app_config.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Upload vehicle image
  Future<String> uploadVehicleImage(String vehicleId, File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}';
      final ref = _firebaseStorage
          .ref('${AppConfig.vehicleImagesPath}/$vehicleId/$fileName');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Upload sale images
  Future<List<String>> uploadSaleImages(
    String saleId,
    List<File> imageFiles,
  ) async {
    try {
      final List<String> imageUrls = [];
      for (var imageFile in imageFiles) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}';
        final ref = _firebaseStorage
            .ref('${AppConfig.saleImagesPath}/$saleId/$fileName');
        await ref.putFile(imageFile);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
      return imageUrls;
    } catch (e) {
      rethrow;
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final ref =
          _firebaseStorage.ref('${AppConfig.profileImagesPath}/$userId/profile');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Delete file
  Future<void> deleteFile(String filePath) async {
    try {
      await _firebaseStorage.ref(filePath).delete();
    } catch (e) {
      rethrow;
    }
  }
}
