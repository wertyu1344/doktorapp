import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'auth_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();

  String get _uid => _authService.currentUser!.uid;

  Future<XFile?> pickImageFromGallery() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
  }

  Future<XFile?> pickImageFromCamera() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
  }

  Future<String> uploadPatientPhoto(String patientId, XFile imageFile) async {
    final uuid = const Uuid().v4();
    final extension = imageFile.path.split('.').last;
    final ref = _storage.ref().child(
      'patients/$_uid/$patientId/${uuid}.$extension',
    );

    final uploadTask = ref.putFile(
      File(imageFile.path),
      SettableMetadata(contentType: 'image/$extension'),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deletePhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      // Fotoğraf zaten silinmiş olabilir
      print('Fotoğraf silinemedi: $e');
    }
  }

  Future<List<String>> uploadMultiplePhotos(
    String patientId,
    List<XFile> images,
  ) async {
    final urls = <String>[];
    for (final image in images) {
      final url = await uploadPatientPhoto(patientId, image);
      urls.add(url);
    }
    return urls;
  }
}
