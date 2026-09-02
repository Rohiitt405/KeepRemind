import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/saved_link_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getOrCreateUserId() async {
    if (_auth.currentUser != null) {
      return _auth.currentUser!.uid;
    }

    final credential = await _auth.signInAnonymously();
    return credential.user!.uid;
  }

  Future<CollectionReference<Map<String, dynamic>>>
  _savedLinksCollection() async {
    final userId = await getOrCreateUserId();

    return _db.collection('users').doc(userId).collection('saved_links');
  }

  Future<String> saveSavedLink(SavedLink savedLink) async {
    final collection = await _savedLinksCollection();
    final document = await collection.add(savedLink.toMap());
    return document.id;
  }

  Stream<List<SavedLink>> getSavedLinks() async* {
    final collection = await _savedLinksCollection();

    yield* collection
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SavedLink.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<List<SavedLink>> getSavedLinkOnce() async {
    final collection = await _savedLinksCollection();

    final snapshot = await collection
      .orderBy('savedAt', descending: true)
      .get();

    return snapshot.docs
      .map((doc) => SavedLink.fromMap(doc.id, doc.data()))
      .toList();
  }

  Future<SavedLink?> getSavedLinkById(String savedLinkId) async {
    try {
      final collection = await _savedLinksCollection();
      final doc = await collection.doc(savedLinkId).get();
      if (doc.exists && doc.data() != null) {
        return SavedLink.fromMap(doc.id, doc.data()!);
      }
    } catch (e) {
      debugPrint('Error fetching saved link by id $savedLinkId: $e');
    }
    return null;
  }

  Future<void> restoreSavedLink(SavedLink savedLink) async {
    final collection = await _savedLinksCollection();

    await collection.add(
      savedLink.toMap(),
    );
  }

  Future<void> updateSavedLink(
    String savedLinkId,
    Map<String, dynamic> data,
  ) async {
    final collection = await _savedLinksCollection();
    await collection.doc(savedLinkId).update(data);
  }

  Future<void> setReviewed(String savedLinkId, bool reviewed) async {
    final collection = await _savedLinksCollection();

    await collection.doc(savedLinkId).update({'isReviewed': reviewed});
  }

  Future<void> deleteSavedLink(String savedLinkId) async {
    final collection = await _savedLinksCollection();

    await collection.doc(savedLinkId).delete();
  }
}
