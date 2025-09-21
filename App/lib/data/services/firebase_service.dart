import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/core/config/env_config.dart';

class FirebaseService extends GetxService {
  late FirebaseFirestore _firestore;
  late FirebaseStorage _storage;

  // Observable properties for real-time status
  final RxBool isConnected = false.obs;
  final RxBool isRealtimeEnabled = true.obs;
  final RxString connectionStatus = 'Initializing...'.obs;

  Future<FirebaseService> init() async {
    try {
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;

      // Set up connection status monitoring
      _setupConnectionMonitoring();

      if (kDebugMode) {
        print('Firebase initialized successfully');
        print('Connected to project: ${EnvConfig.firebaseProjectId}');
      }

      return this;
    } catch (e) {
      connectionStatus.value = 'Connection failed';
      if (kDebugMode) {
        print('Failed to initialize Firebase: $e');
      }
      throw Exception('Failed to initialize Firebase: $e');
    }
  }

  // Monitor connection status
  void _setupConnectionMonitoring() {
    isConnected.value = true;
    connectionStatus.value = 'Connected';
  }

  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;

  // Storage methods
  Future<String> uploadFile(
    String path,
    List<int> fileBytes,
    String fileExt,
  ) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final String filePath = '$path/$fileName';

      final Reference ref = _storage.ref().child(filePath);
      final UploadTask uploadTask = ref.putData(
        Uint8List.fromList(fileBytes),
        SettableMetadata(contentType: 'image/$fileExt'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final Reference ref = _storage.ref().child(filePath);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Firestore methods
  Future<DocumentReference> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await _firestore.collection(collection).add(data);
      return docRef;
    } catch (e) {
      throw Exception('Failed to add document to $collection: $e');
    }
  }

  Future<void> setDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(data);
    } catch (e) {
      throw Exception('Failed to set document in $collection: $e');
    }
  }

  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw Exception('Failed to update document in $collection: $e');
    }
  }

  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document from $collection: $e');
    }
  }

  Future<DocumentSnapshot> getDocument(
    String collection,
    String documentId,
  ) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      return doc;
    } catch (e) {
      throw Exception('Failed to get document from $collection: $e');
    }
  }

  Future<QuerySnapshot> getCollection(
    String collection, {
    Query? query,
    int? limit,
    String? orderBy,
    bool descending = false,
    String? whereField,
    dynamic whereValue,
  }) async {
    try {
      Query collectionQuery = _firestore.collection(collection);

      if (query != null) {
        collectionQuery = query;
      }

      if (whereField != null && whereValue != null) {
        collectionQuery = collectionQuery.where(
          whereField,
          isEqualTo: whereValue,
        );
      }

      if (orderBy != null) {
        collectionQuery = collectionQuery.orderBy(
          orderBy,
          descending: descending,
        );
      }

      if (limit != null) {
        collectionQuery = collectionQuery.limit(limit);
      }

      final snapshot = await collectionQuery.get();
      return snapshot;
    } catch (e) {
      throw Exception('Failed to get collection $collection: $e');
    }
  }

  // Real-time subscriptions
  Stream<QuerySnapshot> subscribeToCollection(
    String collection, {
    Query? query,
    int? limit,
    String? orderBy,
    bool descending = false,
    String? whereField,
    dynamic whereValue,
  }) {
    Query collectionQuery = _firestore.collection(collection);

    if (query != null) {
      collectionQuery = query;
    }

    if (whereField != null && whereValue != null) {
      collectionQuery = collectionQuery.where(
        whereField,
        isEqualTo: whereValue,
      );
    }

    if (orderBy != null) {
      collectionQuery = collectionQuery.orderBy(
        orderBy,
        descending: descending,
      );
    }

    if (limit != null) {
      collectionQuery = collectionQuery.limit(limit);
    }

    return collectionQuery.snapshots();
  }

  Stream<DocumentSnapshot> subscribeToDocument(
    String collection,
    String documentId,
  ) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }
}
