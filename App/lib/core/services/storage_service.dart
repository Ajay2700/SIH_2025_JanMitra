import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:jan_mitra/core/config/env_config.dart';
import 'package:jan_mitra/data/services/supabase_service.dart';

/// Service to handle file uploads and storage operations
class StorageService extends GetxService {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final ImagePicker _imagePicker = ImagePicker();

  // Observable properties
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final RxString lastUploadedUrl = ''.obs;

  // Initialize the service
  Future<StorageService> init() async {
    if (kDebugMode) {
      print('StorageService initialized');
    }
    return this;
  }

  /// Pick an image from the gallery
  Future<XFile?> pickImage({bool fromCamera = false}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null;
    }
  }

  /// Pick multiple images from the gallery
  Future<List<XFile>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );
      return images;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking multiple images: $e');
      }
      return [];
    }
  }

  /// Upload a file to Supabase storage
  Future<String?> uploadFile(
    XFile file, {
    String? bucket,
    String? folder,
  }) async {
    isUploading.value = true;
    uploadProgress.value = 0.0;

    try {
      final String fileName = path.basename(file.path);
      final String fileExt = path.extension(fileName).replaceAll('.', '');
      final String storagePath = folder != null
          ? '$folder/$fileName'
          : fileName;
      final String storageBucket = bucket ?? EnvConfig.ticketAttachmentsBucket;

      // Read file as bytes
      final List<int> fileBytes = await file.readAsBytes();

      // Upload the file
      final String fileUrl = await _supabaseService.uploadFile(
        storageBucket,
        storagePath,
        fileBytes,
        fileExt,
      );

      // Update state
      lastUploadedUrl.value = fileUrl;
      uploadProgress.value = 1.0;
      isUploading.value = false;

      return fileUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      isUploading.value = false;
      return null;
    }
  }

  /// Upload multiple files to Supabase storage
  Future<List<String>> uploadMultipleFiles(
    List<XFile> files, {
    String? bucket,
    String? folder,
  }) async {
    isUploading.value = true;
    uploadProgress.value = 0.0;

    final List<String> uploadedUrls = [];
    final String storageBucket = bucket ?? EnvConfig.ticketAttachmentsBucket;

    try {
      for (int i = 0; i < files.length; i++) {
        final XFile file = files[i];
        final String fileName = path.basename(file.path);
        final String fileExt = path.extension(fileName).replaceAll('.', '');
        final String storagePath = folder != null
            ? '$folder/$fileName'
            : fileName;

        // Read file as bytes
        final List<int> fileBytes = await file.readAsBytes();

        // Upload the file
        final String fileUrl = await _supabaseService.uploadFile(
          storageBucket,
          storagePath,
          fileBytes,
          fileExt,
        );

        uploadedUrls.add(fileUrl);
        uploadProgress.value = (i + 1) / files.length;
      }

      // Update state
      if (uploadedUrls.isNotEmpty) {
        lastUploadedUrl.value = uploadedUrls.last;
      }
      isUploading.value = false;

      return uploadedUrls;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading multiple files: $e');
      }
      isUploading.value = false;
      return uploadedUrls;
    }
  }

  /// Delete a file from Supabase storage
  Future<bool> deleteFile(String fileUrl) async {
    try {
      // Extract the bucket and path from the URL
      final Uri uri = Uri.parse(fileUrl);
      final String path = uri.path;

      // The path will be something like /storage/v1/object/public/bucket/path
      // We need to extract the bucket and the path
      final List<String> parts = path.split('/');
      final int publicIndex = parts.indexOf('public');

      if (publicIndex >= 0 && parts.length > publicIndex + 2) {
        final String bucket = parts[publicIndex + 1];
        final String filePath = parts.sublist(publicIndex + 2).join('/');

        await _supabaseService.deleteFile(bucket, filePath);
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
      return false;
    }
  }
}
