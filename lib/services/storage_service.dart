import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twodo/core/constants/app_constants.dart';
import 'package:twodo/core/utils/app_exceptions.dart';
import 'package:image_cropper/image_cropper.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // UPLOAD USER AVATAR
  Future<String> uploadUserAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child('${AppConstants.userAvatarsPath}/$userId');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(
        message: 'Failed to upload avatar',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw StorageException(
        message: 'An error occurred uploading avatar',
        originalException: e,
      );
    }
  }

  // UPLOAD SPACE IMAGE
  Future<String> uploadSpaceImage({
    required String spaceId,
    required File imageFile,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage
          .ref()
          .child('${AppConstants.spaceImagesPath}/$spaceId/$timestamp');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(
        message: 'Failed to upload image',
        code: e.code,
        originalException: e,
      );
    }
  }

  // UPLOAD FILE TO SPACE
  Future<String> uploadFileToSpace({
    required String spaceId,
    required File file,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final ref = _storage
          .ref()
          .child('${AppConstants.filesPath}/$spaceId/$fileName');

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(
        message: 'Failed to upload file',
        code: e.code,
        originalException: e,
      );
    }
  }

  // DELETE FILE
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw StorageException(
        message: 'Failed to delete file',
        code: e.code,
        originalException: e,
      );
    }
  }

  // GET FILE DOWNLOAD URL
  Future<String> getFileDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref(storagePath);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(
        message: 'Failed to get download URL',
        code: e.code,
        originalException: e,
      );
    }
  }

  // PICK IMAGE FROM GALLERY
  Future<File?> pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      throw StorageException(
        message: 'Failed to pick image',
        originalException: e,
      );
    }
  }

  // PICK IMAGE FROM CAMERA
  Future<File?> pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      throw StorageException(
        message: 'Failed to take photo',
        originalException: e,
      );
    }
  }

  // CROP IMAGE
  Future<File?> cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF7C3AED),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile == null) return null;
      return File(croppedFile.path);
    } catch (e) {
      throw StorageException(
        message: 'Failed to crop image',
        originalException: e,
      );
    }
  }

  // PICK MULTIPLE FILES
  Future<List<File>> pickMultipleFiles() async {
    try {
      // This would need a file picker implementation
      // For now, returning empty list
      return [];
    } catch (e) {
      throw StorageException(
        message: 'Failed to pick files',
        originalException: e,
      );
    }
  }

  // GET FILE SIZE
  Future<int> getFileSize(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      final metadata = await ref.getMetadata();
      return metadata.size ?? 0;
    } on FirebaseException catch (e) {
      throw StorageException(
        message: 'Failed to get file size',
        code: e.code,
        originalException: e,
      );
    }
  }
}
