import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/app_config.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Upload vehicle image
  Future<String> uploadVehicleImage(String vehicleId, File imageFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}';
    final ref = _firebaseStorage
        .ref('${AppConfig.vehicleImagesPath}/$vehicleId/$fileName');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Upload sale images
  Future<List<String>> uploadSaleImages(
    String saleId,
    List<File> imageFiles,
  ) async {
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
  }

  // Upload profile image
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    final ref =
        _firebaseStorage.ref('${AppConfig.profileImagesPath}/$userId/profile');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Delete file
  Future<void> deleteFile(String filePath) async {
    await _firebaseStorage.ref(filePath).delete();
  }
}
