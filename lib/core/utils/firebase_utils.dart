// core/utils/firebase_utils.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class FirebaseUtils {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> uploadImage(File file, String folder) async {
    try {
      final fileName = '${const Uuid().v4()}${path.extension(file.path)}';
      final destination = '$folder/$fileName';

      final ref = _storage.ref().child(destination);
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  static Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  static String generateId() {
    return const Uuid().v4();
  }

  static DocumentReference getDocumentReference(String collection, String id) {
    return _firestore.collection(collection).doc(id);
  }

  static CollectionReference getCollectionReference(String collection) {
    return _firestore.collection(collection);
  }

  static Query query(String collection) {
    return _firestore.collection(collection);
  }

  static Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  static Stream<DocumentSnapshot> streamDocument(String collection, String id) {
    return _firestore.collection(collection).doc(id).snapshots();
  }
}