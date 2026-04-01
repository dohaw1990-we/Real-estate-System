import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/property.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;
  final ImagePicker _picker = ImagePicker();
  final List<Property> _localProperties = [];
  late final StreamController<List<Property>> _propertiesStreamController;

  FirebaseService()
    : _auth = Firebase.apps.isNotEmpty ? FirebaseAuth.instance : null,
      _firestore = Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null,
      _storage = Firebase.apps.isNotEmpty ? FirebaseStorage.instance : null {
    _propertiesStreamController = StreamController<List<Property>>.broadcast();
  }

  @override
  void dispose() {
    _propertiesStreamController.close();
    super.dispose();
  }

  User? get user => _auth?.currentUser;

  Stream<List<Property>> getPropertiesStream() {
    final firestore = _firestore;

    if (firestore == null) {
      // When Firebase is not available, emit local properties through StreamController
      _propertiesStreamController.add(_localProperties);
      return _propertiesStreamController.stream;
    }

    // Combine Firestore and local properties
    return firestore.collection('properties').snapshots().map((snapshot) {
      final firestoreProperties = snapshot.docs
          .map((doc) => Property.fromJson(doc.data()..['id'] = doc.id))
          .toList();
      return [..._localProperties, ...firestoreProperties];
    });
  }

  Stream<List<Property>> getFavoritesStream() {
    final firestore = _firestore;
    final userId = user?.uid;
    if (firestore == null || userId == null) return Stream.value(<Property>[]);
    return firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Property.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<List<Property>> searchProperties({
    String? location,
    double? maxPrice,
    PropertyType? type,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return <Property>[];

    Query<Map<String, dynamic>> query = firestore.collection('properties');
    if (location != null && location.isNotEmpty) {
      query = query
          .where('location', isGreaterThanOrEqualTo: location)
          .where('location', isLessThanOrEqualTo: location + '\uf8ff');
    }
    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type.toString().split('.').last);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Property.fromJson(doc.data()..['id'] = doc.id))
        .toList();
  }

  Future<void> toggleFavorite(Property property) async {
    final firestore = _firestore;
    final userId = user?.uid;
    if (firestore == null || userId == null) return;

    final favoriteRef = firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(property.id);
    final snapshot = await favoriteRef.get();
    if (snapshot.exists) {
      await favoriteRef.delete();
      property.isFavorite = false;
    } else {
      await favoriteRef.set(property.toJson());
      property.isFavorite = true;
    }
    notifyListeners();
  }

  Future<void> addProperty(Property property, List<XFile>? pickedImages) async {
    try {
      List<String> imageUrls = [];
      final firestore = _firestore;
      final storage = _storage;

      // Upload images if storage is available
      if (pickedImages != null && storage != null) {
        for (var image in pickedImages) {
          try {
            final file = File(image.path);
            final ref = storage.ref().child(
              'properties/${DateTime.now().millisecondsSinceEpoch}_${image.name}',
            );
            await ref.putFile(file);
            final url = await ref.getDownloadURL();
            imageUrls.add(url);
          } catch (e) {
            print('Image upload error: $e');
          }
        }
      }

      // Update property with uploaded images
      if (imageUrls.isNotEmpty) {
        property.images = imageUrls;
      }

      // Generate ID for local storage and create new property with ID
      final propertyWithId = Property(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: property.title,
        price: property.price,
        location: property.location,
        type: property.type,
        description: property.description,
        contactPhone: property.contactPhone,
        images: property.images,
        isFavorite: property.isFavorite,
      );

      // Add to local cache immediately for instant UI update
      _localProperties.add(propertyWithId);

      // Emit updated list through StreamController for real-time UI update
      _propertiesStreamController.add(List.from(_localProperties));
      notifyListeners();

      // Add to Firestore if available
      if (firestore != null) {
        await firestore.collection('properties').add(propertyWithId.toJson());
        // Refresh to sync with Firestore
        notifyListeners();
      }
    } catch (e) {
      print('Add property error: $e');
    }
  }

  Future<List<XFile>?> pickImages() async {
    return await _picker.pickMultiImage();
  }
}
